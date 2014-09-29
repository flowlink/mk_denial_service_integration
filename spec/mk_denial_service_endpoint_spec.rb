require 'spec_helper'

describe MKDenialServiceEndpoint do
  include_examples "config credentials"

  let(:order) do
    {
      id: 123,
      billing_address: {
        firstname: "Thomas", last_name: "Lim"
      },
      shipping_address: {
        firstname: "Rene", last_name: "de Boer"
      }
    }
  end

  it "verify order" do
    request = config.merge(order: order)

    VCR.use_cassette("hits") do
      post "/verify_order", request.to_json, auth
      expect(last_response.status).to eq 200
      expect(json_response[:summary]).to match "verified"
    end
  end
end
