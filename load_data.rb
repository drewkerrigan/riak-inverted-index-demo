require 'bundler/setup'
require('riak')
require('./riak_hosts')
require('./models/zombie')

def load_data(filename)
  #client = Riak::Client.new(:protocol => 'pbc')
  client = RiakHosts.new.get_riak_connection

  File.open(filename) do |file|

    file.each_with_index do |line, i|
      fields = line.strip().split(",")
      zombie = Zombie.new(client)
      zombie.from_array(fields)

      zombie.add_index('zip_bin', zombie.data[:zip])
      zombie.add_index('zip_inv', zombie.data[:zip])
      zombie.add_index('geohash_inv', zombie.geohash(4))
      zombie.save

    end
  end
end

filename = ARGV[0]

load_data(filename)