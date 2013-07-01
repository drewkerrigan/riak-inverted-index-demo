require 'bundler/setup'
require('riak')
require('riak_crdts')
require('./riak_hosts')
require('./models/zombie')

def load_data(filename)
  logname = "load_progress.txt"
  #client = Riak::Client.new(:protocol => 'pbc')
  client = RiakHosts.new.get_riak_connection
  zip3 = RiakCrdts::InvertedIndex.new(client, 'zip3_inv')
  log = File.open(logname, "a+")
  target_i = -1

  if log.size > 0
    target_i = `tail -n 1 #{logname}`.split(",")[1].to_i
  end

  File.open(filename) do |file|

    file.each_with_index do |line, i|
      next if i <= target_i

      fields = line.strip().split(",")
      zombie = Zombie.new(client)
      zombie.from_array(fields)

      zip = zombie.data[:zip]
      zip_3 = zip[0, 3]
      geohash = zombie.geohash(4)

      zip3.put_index(zip_3, zip)

      zombie.add_index('zip_bin', zip)
      zombie.add_index('zip_inv', zip)
      zombie.add_index('geohash_inv', geohash)
      zombie.save

      # Retrieve indexes periodically to keep unmerged size smallish
      if i % 20 == 0
          zombie.search_index('zip_inv', zip)
          zombie.search_index('geohash_inv', geohash)
          zip3.get_index(zip_3)
      end

      log.write(Time.now.to_s + "," + i.to_s + "," + ((i / 1000000.0) * 100.0).round(3).to_s + "%\n")
    end
  end

  log.close unless log == nil
end

filename = ARGV[0]

load_data(filename)