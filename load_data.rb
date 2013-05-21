require 'bundler/setup'
require('riak')
require('geohash')
require('./models/zombie')

def load_data(filename)
  client = Riak::Client.new(:protocol => 'pbc')

  File.open(filename) do |file|

    file.each_with_index do |line, i|
      fields = line..strip().split(",")
      zombie = Zombie.new()
      zombie.from_array(fields)

      city = "#{zombie.data[:city]}, #{zombie.data[:state]}"
      city_3 = city[0, 3]
      geohash = GeoHash.encode(zombie.data[:latitude].to_f, zombie.data[:longitude].to_f, 1)[0, 4]

      riak_obj = client['zombies'].new(zombie.data[:ssn])
      riak_obj.data = zombie.data
      riak_obj.indexes['zip_bin'] << zombie.data[:zip]
      riak_obj.indexes['zip_inv'] << zombie.data[:zip]
      riak_obj.indexes['city_inv'] << zombie.data[:city]
      riak_obj.indexes['geohash_inv'] << geohash
      riak_obj.store

      # Sibling resolution takes places when index is retrieved. Do periodically to avoid sibling explosion
      if i % 20 == 0
        client['zombies'].get_index('zip_inv', zombie.data[:zip])
        client['zombies'].get_index('city_inv', city)
        client['zombies'].get_index('geohash_inv', geohash)
      end

    end
  end
end

filename = ARGV[0]

load_data(filename)