require 'bundler/setup'
require('riak')
require('./index/inverted_index')


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
  client = Riak::Client.new

  state_abv_idx = InvertedIndex.new(client, 'state_abv')
  state_idx = InvertedIndex.new(client, 'state')
  state_city_idx = InvertedIndex.new(client, 'state_city')
  city_idx = InvertedIndex.new(client, 'city')
  city_3_idx = InvertedIndex.new(client, 'city3')

  puts filename
  File.open(filename) do |file|
    skip = true
    file.each do |line|
      if skip
        skip = false
        next
      end
      fields = line.split(',')
      zip_data = ZipData.new(fields)
      riak_obj = client['zip_codes'].new(zip_data.data[:zipcode])
      riak_obj.data = zip_data.data
      riak_obj.indexes['city_bin'] << zip_data.data[:city]
      riak_obj.indexes['state_bin'] << zip_data.data[:state]
      riak_obj.store

      city_str = "#{zip_data.data[:city]}, #{zip_data.data[:state]}"

      state_abv_idx.put_index(zip_data.data[:stateabbreviation], zip_data.data[:zip])
      state_city_idx.put_index(zip_data.data[:state], city_str)
      state_idx.put_index(zip_data.data[:state], zip_data.data[:zip])
      city_idx.put_index(city_str, zip_data.data[:zip])
      city_3_idx.put_index(zip_data.data[:city][0, 3], city_str)
    end
  end
end

filename = ARGV[0]

load_data(filename)