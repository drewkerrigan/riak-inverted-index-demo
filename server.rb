require 'bundler/setup'
require 'sinatra'
require 'geohash'
require 'riak_crdts'
require './models/zombie'
require './riak_hosts'

client = RiakHosts.new().get_riak_connection
zip3_idx = RiakCrdts::InvertedIndex.new(client, 'zip3_inv')

# Get
get '/' do
  erb :index
end

get '/query/zip3/:zip' do

  zip = params[:zip]
  zip3 = zip[0, 3]

  zips = zip3_idx.get_index(zip3)
  results = zips.members.to_a

  if zip.length > 3
    results = results.select { |item| item.start_with? zip  }
  end

  return results.sort.to_json
end

get '/query/:index/:zip' do
  zombie = Zombie.new(client)
  results = zombie.search_index(params[:index], params[:zip])

  results.to_json
end

get '/query/geo' do
  zombie = Zombie.new(client)
  zombie.data[:latitude] = params[:lat].to_f
  zombie.data[:longitude] = params[:lon].to_f
  results = zombie.search_index('geohash_inv', zombie.geohash(4))

  results.to_json
end

put '/zombie/:index' do
  data = JSON.parse(request.body.read)

  zombie = Zombie.new(client)
  zombie.from_hash(data)
  zombie.add_index(params[:index], zombie.data[:zip])
  zombie.save()

  nil
end