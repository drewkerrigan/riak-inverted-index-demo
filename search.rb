require 'riak'
require './models/zombie'

class Search

  attr_accessor :index, :query, :client

  def initialize(index, query)
    @index = index
    @query = query
    @client = Riak::Client.new
  end

  def run()
    zombies = []
    results = index_search

    unless results.nil?
      for zombie_key in results
        zombies << @client['zombies'].get(zombie_key).data
      end
    end

    return zombies
  end

  def index_search()
    @client['zombies'].get_index(@index, @query)
  end
end