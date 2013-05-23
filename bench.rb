require 'bundler/setup'
require 'riak'

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
    @client = Riak::Client.new(:protocol => 'pbc')
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

  def run_test(puts, gets, duration)
    start = Time.now

    @get_stats.start()
    @put_stats.start()

    # Delta is in seconds
    while (Time.now - start) < duration do
       (1 .. puts).each do
         @put_stats.split
         key = key_count.to_i.to_s
         #puts 'put', key
         self.put_with_index(key, @key_count, @index_name, key)
         @put_stats.split_stop
       end
       (1 .. gets).each do
         @get_stats.split
         key = rand(@key_count).to_i.to_s
         #puts 'get', key
         self.get_with_index(key, @index_name)
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

bench = Bench.new(bucket_name, index_name)

bench.run_test(puts, gets, duration)

puts 'Get', bench.get_stats.stats
puts 'Put', bench.put_stats.stats
