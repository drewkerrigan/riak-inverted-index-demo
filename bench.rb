require 'bundler/setup'
require 'riak'
require './riak_hosts'
require './models/zombie'

class Stat
  attr_accessor :start, :stop, :split_start, :measurements

  def initialize
    @start = self.time
    @measurements = Hash.new(0)
  end

  def time
    Time.now.to_f * 1000.0
  end

  def start
    @start = time
  end

  def stop
    @stop = time
  end

  def split
    @split_start = time
  end

  def split_stop
    split_time = time - @split_start

    measurement = @measurements[split_time]
    measurement +=1

    @measurements[split_time] = measurement
  end

  def stats
    min = 999999
    max = -999999
    count = 0
    total = 0

    @measurements.keys.each do | key |
      if key < min
        min = key
      end
      if key > max
        max = key
      end

      count += @measurements[key]
      total += key * @measurements[key]
    end

    if count > 0
      avg = total / count
    else
      avg = 0
    end
    [min, avg, max, count]
  end

  def total_time
    @stop - @start
  end
end

class Bench
  attr_accessor :client, :key_count, :bucket_name, :bucket, :index_name, :get_stats, :put_stats

  def initialize(bucket_name, index_name)
    @client = RiakHosts.new.get_riak_connection
    @bucket_name = bucket_name
    @bucket = @client[@bucket_name]
    @index_name = index_name
    @put_stats = Stat.new
    @get_stats = Stat.new

    @key_count = 0
  end

  def put_with_index(key, value, index, index_value)
    obj = @bucket.new(key)
    obj.content_type = 'text/plain'
    obj.data = value

    obj.indexes[index] << index_value

    obj.store(options={:returnbody => false})
  end

  def get_with_index(key, index)
    obj = @bucket.get_index(index, key)
  end

  def run_test(puts, gets, duration, default_index_value)
    start = Time.now

    @get_stats.start()
    @put_stats.start()

    index_value = default_index_value

    # Delta is in seconds
    while (Time.now - start) < duration do
      key = key_count.to_i.to_s
      if !default_index_value.nil?
        index_value = key
      end

      (1 .. puts).each do
        @put_stats.split
        #puts 'put', key
        self.put_with_index(key, @key_count, @index_name, index_value)
        @put_stats.split_stop
      end
      (1 .. gets).each do
        @get_stats.split
        index_key = default_index_value.nil? ? rand(@key_count).to_i.to_s : default_index_value
        #puts 'get', key
        self.get_with_index(index_key, @index_name)
        @get_stats.split_stop
      end

      @key_count += 1
    end
    @get_stats.stop()
    @put_stats.stop()
  end
end

bucket_name = ARGV[0]
index_name = ARGV[1]
gets = ARGV[2].to_i
puts = ARGV[3].to_i
duration = ARGV[4].to_i

default_index_value = ARGV[5]

bench = Bench.new(bucket_name, index_name)

bench.run_test(puts, gets, duration, default_index_value)

get_stats = ['get'] + bench.get_stats.stats.map {|value| '%.2f' % value }
put_stats = ['put'] + bench.put_stats.stats.map {|value| '%.2f' % value }


puts get_stats.join(',')
puts put_stats.join(',')
