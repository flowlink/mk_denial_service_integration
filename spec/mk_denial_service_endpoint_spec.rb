require 'spec_helper'

describe MKDenialServiceEndpoint do
  let(:config) do
    {
      mk_denial_service_login: ENV['MK_DENIAL_SERVICE_LOGIN'],
      mk_denial_service_password: ENV['MK_DENIAL_SERVICE_PASSWD']
    }
  end

  let(:order) do
    {
      id: 123,
      billing_address: {
        firstname: "John", last_name: "Smith"
      },
      shipping_address: {
        firstname: "William", last_name: "Shakespear"
      }
    }
  end

  it "verify order" do
    request = config.merge(order: order)

    VCR.use_cassette("mk_denial_service") do
      post "/verify_order", request.to_json, auth
      expect(last_response.status).to eq 200
      expect(json_response[:summary]).to match "verified"
    end
  end
end
