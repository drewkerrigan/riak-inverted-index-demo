require 'bundler/setup'
require 'sinatra'
require './search'

# Get
get '/' do
  erb :index
end

get '/query/:method/:zip' do
  search = Search.new(params[:method],params[:zip])
  results = search.run()

  erb :query_results, :locals => {:results => results}, :layout => false
end

get '/map' do
  erb :map, :layout => false
end