require "sinatra"
require "endpoint_base"

require File.expand_path(File.dirname(__FILE__) + '/lib/mk_denial_service')
require File.expand_path(File.dirname(__FILE__) + '/lib/mk_denial_service_integration/order')

class MKDenialServiceEndpoint < EndpointBase::Sinatra::Base
  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end if ENV['HONEYBADGER_KEY'].present?

  post "/verify_order" do
    order = MKDenialServiceIntegration::Order.new(@config, @payload)
    add_object "order", order.updated_object
    result 200, "Screening result from MK Datas denied list service is '#{order.mkd_screen_result}'"
  end
end
