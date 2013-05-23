require 'bundler/setup'
require('riak')
require('./models/zombie')

def load_data(filename)
  client = Riak::Client.new(:protocol => 'pbc')

  File.open(filename) do |file|

    file.each_with_index do |line, i|
      fields = line.strip().split(",")
      zombie = Zombie.new(client)
      zombie.from_array(fields)

      zombie.add_index('zip_bin', zombie.data[:zip])
      zombie.add_index('zip_inv', zombie.data[:zip])
      zombie.add_index('city_inv', zombie.citystate)
      zombie.add_index('geohash_inv', zombie.geohash(4))
      zombie.save

      # Sibling resolution takes places when index is retrieved. Do periodically to avoid sibling explosion
      if i % 20 == 0
        zombie.search_index('zip_inv', zombie.data[:zip])
        zombie.search_index('city_inv', zombie.citystate)
        zombie.search_index('geohash_inv', zombie.geohash(4))
      end

    end
  end
end

filename = ARGV[0]

load_data(filename)