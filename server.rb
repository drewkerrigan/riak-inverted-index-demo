require 'bundler/setup'
require 'sinatra'
require 'geohash'
require './search'

# Get
get '/' do
  erb :index
end

get '/query/:method/:zip' do
  search = Search.new(params[:method],params[:zip])
  results = search.run()

  erb :generic_json, :locals => {:json => results.to_json}, :layout => false
end

get '/query/geo' do
  lat = params[:lat].to_f
  lon = params[:lon].to_f

  geohash = GeoHash.encode(lat, lon, 1)[0, 4]

  search = Search.new('geohash_inv', geohash)
  results = search.run()

  erb :generic_json, :locals => {:json => results.to_json}, :layout => false
end

get '/map' do
  erb :map, :layout => false
end