require 'bundler/setup'
require('riak')
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
      riak_obj.indexes['zip_inv'] << zombie.data[:zip]
      riak_obj.store

    end
  end
end

filename = ARGV[0]

load_data(filename)