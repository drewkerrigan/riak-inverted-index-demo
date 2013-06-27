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
  i = 0

  if log.size > 0
    target_i = `tail -n 1 #{logname}`.split(",")[1].to_i
  end

  File.open(filename) do |file|

    file.each_with_index do |line, i|
      i+=1
      next if i <= target_i

      fields = line.strip().split(",")
      zombie = Zombie.new(client)
      zombie.from_array(fields)

      zip = zombie.data[:zip]

      zip3.put_index(zip[0, 3], zip)

      zombie.add_index('zip_bin', zip)
      zombie.add_index('zip_inv', zip)
      zombie.add_index('geohash_inv', zombie.geohash(4))
      zombie.save

      log.write(Time.now.to_s + "," + i.to_s + "," + ((i / 1000000.0) * 100.0).round(3).to_s + "%\n")
    end
  end

  log.close unless log == nil
end

filename = ARGV[0]

load_data(filename)