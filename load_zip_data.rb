require 'bundler/setup'
require('riak')
require('./index/inverted_index')

class Timer
  attr_accessor :start, :stop, :split_start, :split_count

  def initialize
    self.start = time
    self.split_count = 0
  end

  def time
    return Time.now.to_f * 1000.0
  end

  def start
    self.start = time
  end

  def stop
    self.stop = time
  end

  def split
    self.split_start = time
  end

  def split_stop
    self.split_count += 1
    return time - self.split_start
  end

  def total_time
    return self.stop - self.start
  end
end

class ZipData
  attr_accessor :data
  def initialize(data_array)
    fields = [:zipcode, :stateabbreviation, :latitude, :longitude, :city, :state]
    self.init_from_row(fields, data_array)
  end

  def init_from_row(fields, data_array)
    self.data = Hash[fields.zip data_array]
  end
end

def load_data(filename)
  client = Riak::Client.new(:protocol => 'pbc')

  state_idx = InvertedIndex.new(client, 'state')
  state_city_idx = InvertedIndex.new(client, 'state_city')
  city_idx = InvertedIndex.new(client, 'city')
  city_3_idx = InvertedIndex.new(client, 'city3')

  timer = Timer.new
  timer.start

  puts filename
  File.open(filename) do |file|
    skip = true
    file.each_with_index do |line, i|
      if skip
        skip = false
        next
      end
      fields = line.strip.split(',')
      zip_data = ZipData.new(fields)
      riak_obj = client['zip_codes'].new(zip_data.data[:zipcode])
      riak_obj.data = zip_data.data
      riak_obj.indexes['city_bin'] << zip_data.data[:city]
      riak_obj.indexes['state_bin'] << zip_data.data[:state]
      timer.split
      riak_obj.store
      store_time = timer.split_stop

      city = zip_data.data[:city]
      city_3 = city[0, 3]
      state = zip_data.data[:stateabbreviation] + ' '
      city_str = "#{city}, #{state}"
      zip = zip_data.data[:zipcode]

      timer.split
      state_city_idx.put_index(state, city_str)
      state_city_time = timer.split_stop

      timer.split
      state_idx.put_index(state, zip)
      state_time = timer.split_stop

      timer.split
      city_idx.put_index(city_str, zip)
      city_time = timer.split_stop

      timer.split
      city_3_idx.put_index(city_3, city_str)
      city_3_time = timer.split_stop

      # Trigger sibling resolution by reading the written index
      if i % 20 == 0
        state_city_idx.get_index(state)
        state_idx.get_index(state)
        city_idx.get_index(city_str)
        city_3_idx.get_index(city_3)
      end

      print "\r%d %s %d, %d, %d, %d, %d                      " % [i, state, store_time, state_city_time, state_time, city_time, city_3_time]
    end
  end

  timer.stop
  puts "Finished in %.3f seconds" % (timer.total_time / 1000.0)
end

filename = ARGV[0]

load_data(filename)