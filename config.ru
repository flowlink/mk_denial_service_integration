require 'rubygems'
require 'bundler'

Bundler.require(:default)

require "./mk_denial_service_endpoint"

run MKDenialServiceEndpoint
