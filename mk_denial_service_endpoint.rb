require "sinatra"
require "endpoint_base"

require File.expand_path(File.dirname(__FILE__) + '/lib/mk_denial_service')

class MKDenialServiceEndpoint < EndpointBase::Sinatra::Base
  endpoint_key ENV['ENDPOINT_KEY']

  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end if ENV['HONEYBADGER_KEY'].present?

  post "/verify_order" do
    shipping = @payload[:order][:shipping_address]
    billing = @payload[:order][:billing_address]
    response = MKDenialService.new(@config).search_dpl billing, shipping

    add_object "order", { id: @payload[:order][:id], mkd_hits: response[:hits] }
    result 200, "Order billing and shipping address verified on MK Denial Service"
  end
end
