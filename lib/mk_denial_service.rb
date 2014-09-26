require 'savon'

class MKDenialService
  attr_reader :credentials, :client

  def initialize(config)
    @credentials = {
      "Username" => config[:mk_denial_service_login],
      "Password" => config[:mk_denial_service_password]
    }

    @client = Savon.client(
      ssl_verify_mode: :none,
      wsdl: 'https://sandbox.mkdenial.com/dplv3_1.asmx?wsdl',
      log_level: :debug,
      log: true
    )
  end

  # Options:
  #
  #   nametosearch = "john smith"; // supply the name to search for
  #   countrytosearch = "US"; // country to search
  #   streettosearch = ""; // street to search
  #   citytosearch = "Lompoc"; // city to search
  #   statetosearch = "CA"; // state to search
  #
  #   MaxReturnHits: maximum hits to return and cannot exceed the server maximum
  #     (1000). set to 0 to default to server maximum
  #   AlwaysIncludeUnkownCountry: return entries with unspecified country (recommended)
  #   ExcludeCommonWords: recommended true
  #   excludeWeakAliases: weak alias toggle
  #
  def search_dpl(billing_address = {}, shipping_address = {})
    response = client.call(
      :search_dpl,
      message: {
        credentials: credentials,
        request: {
          "AlwaysIncludeUnknownCountry" => true,
          "Connect" => "and",
          "ExcludeCommonWords" => true,
          "ExcludeWeakAliases" => true,
          "MaxReturnHits" => 0,
          "Groups" => [
            {
              "Group" => {
                "Connect" => "or",
                "Matches" => [
                  {
                    "Match" => {
                      "Field" => "Name",
                      "Keyword" => "#{billing_address[:firstname]} #{billing_address[:lastname]}",
                      "Level" => 1,
                      "Scope" => "Word",
                      "Type" => "Is"
                    }
                  }
                ]
              }
            },
            {
              "Group" => {
                "Connect" => "or",
                "Matches" => [
                  {
                    "Match" => {
                      "Field" => "Name",
                      "Keyword" => "#{shipping_address[:firstname]} #{shipping_address[:lastname]}",
                      "Level" => 1,
                      "Scope" => "Word",
                      "Type" => "Is"
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    )

    response.body
  end
end
