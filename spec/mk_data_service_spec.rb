require 'spec_helper'

describe MKDenialService do
  it "calls webservice" do
    VCR.use_cassette("mk_denial_service") do
      subject.search_dpl
    end
  end
end
