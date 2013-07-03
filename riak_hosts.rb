require 'bundler/setup'
require('riak')

class Host
  attr_accessor :hostname, :port

  def initialize(hostname, port)
    self.hostname = hostname
    self.port = port
  end

  def get_riak_definition
    return {:host => self.hostname, :protocol => 'pbc', :pb_port => self.port}
  end
end

class RiakHosts
  attr_accessor :hosts, :hosts_file

  def initialize
    self.hosts = []
    self.hosts_file = './hosts'
  end

  def read_hosts
    File.open(self.hosts_file) do |file|

      file.each_with_index do |line, i|
        host, port = self.read_line(line)
        self.hosts << Host.new(host, port)
      end
    end
  end

  def read_line(line)
    parts = line.split(':')
    if parts.length == 1
      return [parts[0], 8087]
    elsif parts.length == 2
      return [parts[0], parts[1].to_i]
    else
      puts 'Line does not conform to expected hostname:port format'
      return ['localhost', 8087]
    end

  end

  def get_riak_connection
    self.read_hosts
    riak_hosts = []
    self.hosts.each do |riak_host|
      riak_hosts << riak_host.get_riak_definition
    end

    Riak::Client.new(:nodes => riak_hosts, :protocol => 'pbc')
  end
end