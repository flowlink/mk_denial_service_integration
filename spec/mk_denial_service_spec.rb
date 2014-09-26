require 'spec_helper'

describe MKDenialService do
  let(:config) do
    {
      mk_denial_service_login: ENV['MK_DENIAL_SERVICE_LOGIN'],
      mk_denial_service_password: ENV['MK_DENIAL_SERVICE_PASSWD']
    }
  end

  subject { described_class.new config }

  it "calls webservice" do
    VCR.use_cassette("mk_denial_service") do
      subject.search_dpl(
        { firstname: "Barack", lastname: "Obama" },
        { firstname: "The", lastname: "Godzilla" },
      )
    end
  end
end
