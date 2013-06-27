require 'bundler/setup'
require('riak')
require('riak_crdts')
require('./riak_hosts')
require('./models/zombie')

def time
  Time.now.to_f * 1000.0
end

def load_data(filename)

  #client = Riak::Client.new(:protocol => 'pbc')
  client = RiakHosts.new.get_riak_connection
  zip3 = RiakCrdts::InvertedIndex.new(client, 'zip3_inv')

  start = time

  File.open(filename) do |file|

    file.each_with_index do |line, i|
      fields = line.strip().split(",")
      zombie = Zombie.new(client)
      zombie.from_array(fields)

      zip = zombie.data[:zip]

      zip3.put_index(zip[0, 3], zip)

      zombie.add_index('zip_bin', zip)
      zombie.add_index('zip_inv', zip)
      zombie.add_index('geohash_inv', zombie.geohash(4))
      zombie.save

      if i % 50 == 0
        total_time = (time - start)/1000
        ops_sec = i / total_time
        print "\r#{ops_sec} rec/sec                             "
      end

    end
  end
end

filename = ARGV[0]

load_data(filename)