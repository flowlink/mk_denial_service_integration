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
    hits = order.verify!

    add_object "order", { id: @payload[:order][:id], mkd_hits: hits } if hits
    result 200, "Order billing and shipping address verified on MK Denial Service"
  end
end
