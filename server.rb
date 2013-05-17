require 'bundler/setup'
require 'sinatra'
require 'riak'
require './index/inverted_index'
require './zombie'

# Get
get '/' do
  erb :index
end

get '/2iquery' do
  erb :sec_query
end

get '/iiquery' do
  erb :ii_query
end

get '/2i' do
  client = Riak::Client.new

  results = client['zombies'].get_index('zip_bin', params[:zip])

  erb :query_results, :locals => {:results => results}
end

get '/ii' do
  client = Riak::Client.new

  inv_idx = InvertedIndex.new(client, 'zombies')

  results = inv_idx.get_index(params[:zip])

  erb :query_results, :locals => {:results => results.members.to_a}
end

get '/load' do
  client = Riak::Client.new
  zombies = []

  inv_idx = InvertedIndex.new(client, 'zombies')

  File.open("data.csv") do |file|

    file.each do |line|
      fields = line.split(",")
      zombie = Zombie.new()
      zombie.from_array(fields)

      zombies << zombie.data

      riak_obj = client['zombies'].new(zombie.data[:ssn])
      riak_obj.data = zombie.data
      riak_obj.indexes['zip_bin'] << zombie.data[:zip]
      riak_obj.store

      inv_idx.put_index(zombie.data[:zip], zombie.data[:ssn])
    end
  end

  erb :load, :locals => {:zombies => zombies}
end