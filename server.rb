require 'bundler/setup'
require 'sinatra'
require 'riak'

get '/hi' do
  "Hello World!"
end