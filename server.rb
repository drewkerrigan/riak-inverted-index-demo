require 'bundler/setup'
require 'sinatra'
require 'geohash'
require './models/zombie'

# Get
get '/' do
  erb :index
end

get '/query/:index/:zip' do
  zombie = Zombie.new()
  results = zombie.search_index(params[:index], params[:zip])

  erb :generic_json, :locals => {:json => results.to_json}, :layout => false
end

put '/zombie/:index' do
  data = JSON.parse(request.body.read)

  zombie = Zombie.new()
  zombie.from_hash(data)
  zombie.add_index(params[:index], zombie.data[:zip])
  zombie.save()

  status 204
end

get '/query/geo' do
  zombie = Zombie.new()
  zombie.data[:latitude] = params[:lat].to_f
  zombie.data[:longitude] = params[:lon].to_f

  results = zombie.search_index('geohash_inv', zombie.geohash(4))

  erb :generic_json, :locals => {:json => results.to_json}, :layout => false
end