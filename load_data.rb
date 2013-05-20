require 'bundler/setup'
require('riak')
require('./index/inverted_index')
require('./zombie')

def load_data(filename)
  client = Riak::Client.new

  inv_idx = InvertedIndex.new(client, 'zombies')

  File.open(filename) do |file|

    file.each do |line|
      fields = line.split(",")
      zombie = Zombie.new()
      zombie.from_array(fields)

      riak_obj = client['zombies'].new(zombie.data[:ssn])
      riak_obj.data = zombie.data
      riak_obj.indexes['zip_bin'] << zombie.data[:zip]
      riak_obj.store

      inv_idx.put_index(zombie.data[:zip], zombie.data[:ssn])
    end
  end
end

filename = ARGV[0]

load_data(filename)