require 'bundler/setup'
require 'sinatra'
require 'riak-client'

get '/hi' do
  "Hello World!"
end