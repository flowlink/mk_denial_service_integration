require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'lib/mk_denial_service')
require File.join(File.dirname(__FILE__), '..', 'lib/mk_denial_service_integration/order')
require File.join(File.dirname(__FILE__), '..', 'mk_denial_service_endpoint')

Dir["./spec/support/**/*.rb"].each { |f| require f }

require 'spree/testing_support/controllers'

Sinatra::Base.environment = 'test'

ENV['MK_DENIAL_SERVICE_LOGIN'] ||= 'user'
ENV['MK_DENIAL_SERVICE_PASSWD'] ||= 'passwd'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data("MK_DENIAL_SERVICE_LOGIN") { ENV["MK_DENIAL_SERVICE_LOGIN"] }
  c.filter_sensitive_data("MK_DENIAL_SERVICE_PASSWD") { ENV["MK_DENIAL_SERVICE_PASSWD"] }
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers
end
