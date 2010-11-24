#!/usr/bin/ruby

require 'rubygems'
gem 'activesupport', '= 2.3.9'
require 'fastercsv'
require 'chronic'
require 'active_support'
require 'sinatra'
require 'haml'
require 'nokogiri'

require 'lib/pivotal_attribution'

get '/' do
  haml :index
end



use_faker = false
if ARGV[2] && ARGV[2] == "faker"
  require 'faker'
  use_faker = true
end

post '/:project_id' do
  PivotalAttribution::Auth.retrieve(params[:project_id], params[:username], params[:password])
  #PivotalAttribution::Main.run("/home/josh/Downloads/#{params[:csv]}", params[:since])
end
