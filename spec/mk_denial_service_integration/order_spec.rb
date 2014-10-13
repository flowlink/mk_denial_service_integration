require 'spec_helper'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/numeric/time'

module MKDenialServiceIntegration
  describe Order do
    include_examples "config credentials"

    it "builds one group filter when addresses are equal" do
      order = {
        billing_address: {
          firstname: "Thomas", lastname: "Lim", country: "SG"
        },
        shipping_address: {
          firstname: "Thomas", lastname: "Lim", country: "SG"
        }
      }

      subject = described_class.new({}, order: order)
      expect(subject.groups.count).to eq 1
    end

    it "builds two groups filter when addresses are not equal" do
      order = {
        billing_address: {
          firstname: "Thomas", lastname: "Lim", country: "SG"
        },
        shipping_address: {
          firstname: "Thomas", lastname: "Limm", country: "SG"
        }
      }

      subject = described_class.new({}, order: order)
      expect(subject.groups.count).to eq 2
    end

    it "verifies and return hits if any" do
      order = {
        billing_address: {
          firstname: "Thomas", lastname: "Lim", country: "SG"
        },
        shipping_address: {
          firstname: "René", lastname: "de Boer", country: "NL"
        }
      }

      subject = described_class.new(config, order: order)

      VCR.use_cassette("hits") do
        hits = subject.hits
        expect(hits.first[:name]).to match order[:billing_address][:firstname]
      end
    end

    it "verifies and return nil if no hits found" do
      order = {
        billing_address: {
          firstname: "NONONONONONO", lastname: "NONONNO", country: "SG"
        },
        shipping_address: {
          firstname: "NONONONONONO", lastname: "NONONNO", country: "SG"
        }
      }

      subject = described_class.new(config, order: order)

      VCR.use_cassette("no_hits") do
        expect(subject.hits).to eq nil
      end
    end

    it "checks date range for denied or approved" do
      subject = described_class.new config, { order: {} }

      hits = [
        { start_date: "2013-01-16T00:00:00+00:00", end_date: "2013-02-16T00:00:00+00:00" },
        { start_date: "2014-01-16T00:00:00+00:00", end_date: "2014-02-16T00:00:00+00:00" }
      ]
      expect(subject.mkd_screen_result hits).to eq "approved"

      hits = [
        { start_date: 10.days.ago, end_date: 10.days.from_now },
        { start_date: 10.days.ago, end_date: "2014-02-16T00:00:00+00:00" }
      ]
      expect(subject.mkd_screen_result hits).to eq "denied"
    end
  end
end
