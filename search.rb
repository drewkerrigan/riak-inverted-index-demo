require 'riak'
require './models/zombie'

class Search

  attr_accessor :method, :query, :client

  SECONDARY="secondary"
  INVERTED="inverted"

  def initialize(method, query)
    @method = method
    @query = query
    @client = Riak::Client.new
  end

  def run()
    unless [SECONDARY, INVERTED].include? @method
      raise "Unsupported method"
    end

    method_name = @method + "_index_search"

    zombies = []
    results = self.send(method_name) if self.respond_to? method_name


    p results

    unless results.nil?
      for zombie_key in results
        p zombie_key
        zombies << @client['zombies'].get(zombie_key).data
      end
    end

    return zombies
  end

  def secondary_index_search()
    @client['zombies'].get_index('zip_bin', @query)
  end

  def inverted_index_search()
    @client['zombies'].get_index('zip_inv', @query)
    #inv_idx = InvertedIndex.new(@client, 'zombies')
    #inv_idx.get_index(@query)
  end

end