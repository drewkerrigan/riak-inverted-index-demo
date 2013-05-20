require 'bundler/setup'
require('riak')
require('./index/inverted_index')
require('./models/zombie')

def load_data(filename)
  client = Riak::Client.new(:protocol => 'pbc')

  inv_idx = InvertedIndex.new(client, 'zombies')
  state_city_idx = InvertedIndex.new(client, 'state_city')
  city_3_idx = InvertedIndex.new(client, 'city_3')
  city_zip_idx = InvertedIndex.new(client, 'city_zip')

  File.open(filename) do |file|

    file.each_with_index do |line, i|
      fields = line.split(",")
      zombie = Zombie.new()
      zombie.from_array(fields)

      city = "#{zombie.data[:city]}, #{zombie.data[:state]}"
      city_3 = city[0, 3]

      riak_obj = client['zombies'].new(zombie.data[:ssn])
      riak_obj.data = zombie.data
      riak_obj.indexes['zip_bin'] << zombie.data[:zip]
      riak_obj.store

      inv_idx.put_index(zombie.data[:zip], zombie.data[:ssn])
      state_city_idx.put_index(zombie.data[:state], city)
      city_3_idx.put_index(city_3, city)
      city_zip_idx.put_index(city, zombie.data[:zip])

      # Do read-repair (by retrieving index) periodically to avoid sibling explosion
      if i % 20 == 0
        inv_idx.get_index(zombie.data[:zip])
        state_city_idx.get_index(zombie.data[:state])
        city_3_idx.get_index(city_3)
        city_zip_idx.get_index(city)
      end

    end
  end
end

filename = ARGV[0]

load_data(filename)