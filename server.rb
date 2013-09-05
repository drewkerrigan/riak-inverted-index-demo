require 'bundler/setup'
require 'sinatra'
require 'geohash'
require 'riak_crdts'
require './models/zombie'
require './riak_hosts'
require 'newrelic_rpm'

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

  results.sort.to_json
end

get '/query/:index/:zip' do
  start = (params.keys.include?('start')) ? params[:start] : 1
  #Don't expose count
  #count = (params.key.include?('count')) ? params[:count] : 50
  zombie = Zombie.new(client)

  #validate index
  index = params[:index]
  return 'Invalid index' unless ['zip_inv', 'zip_bin'].include? index

  keys = zombie.search_index(params[:index], params[:zip])
  results = zombie.fetch_with_pagination(keys, start.to_i)

  results.to_json
end

get '/query/geo' do
  start = (params.keys.include?('start')) ? params[:start] : 1
  #Don't expose count
  #count = (params.key.include?('count')) ? params[:count] : 50
  zombie = Zombie.new(client)
  zombie.data[:latitude] = params[:lat].to_f
  zombie.data[:longitude] = params[:lon].to_f
  keys = zombie.search_index('geohash_inv', zombie.geohash(4))
  results = zombie.fetch_with_pagination(keys, start.to_i)

  results.to_json
end

#put '/zombie/:index' do
#  data = JSON.parse(request.body.read)
#
#  zombie = Zombie.new(client)
#  zombie.from_hash(data)
#  zombie.add_index(params[:index], zombie.data[:zip])
#  zombie.save()
#
#  nil
#end