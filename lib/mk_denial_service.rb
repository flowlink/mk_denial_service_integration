require 'savon'

class MKDenialService
  attr_reader :credentials

  def initialize(config)
    @credentials = {
      "Username" => config[:mk_denial_service_login],
      "Password" => config[:mk_denial_service_password]
    }
  end

  # See https://mkdataservices.zendesk.com/hc/en-us/articles/202870130-Objects
  # for detailed description of each field
  #
  # Options:
  #
  #   MaxReturnHits: maximum hits to return and cannot exceed the server maximum
  #     (1000). set to 0 to default to server maximum
  #   AlwaysIncludeUnkownCountry: return entries with unspecified country (recommended)
  #   ExcludeCommonWords: recommended true
  #   excludeWeakAliases: weak alias toggle
  #
  def search_dpl(groups = [])
    response = client.call(
      :search_dpl,
      message: {
        credentials: credentials,
        request: {
          "AlwaysIncludeUnknownCountry" => true,
          "Connect" => "or",
          "ExcludeCommonWords" => true,
          "ExcludeWeakAliases" => true,
          "MaxReturnHits" => 100,
          "Groups" => groups
        }
      }
    )

    response.body
  end

  def build_group(data)
    {
      "Group" => {
        "Connect" => "and",
        "Matches" => [
          {
            "Match" => {
              "Field" => "Name",
              "Keyword" => "#{data[:lastname]}, #{data[:firstname]}",
              "Level" => 2,
              "Scope" => "Word",
              "Type" => "Is"
            }
          },
          {
            "Match" => {
              "Field" => "Country",
              "Keyword" => data[:country],
              "Type" => "Is"
            }
          }
        ]
      }
    }
  end

  private
    def client
      @client ||= Savon.client(
        ssl_verify_mode: :none,
        wsdl: 'https://sandbox.mkdenial.com/dplv3_1.asmx?wsdl',
        log_level: :debug,
        log: true
      )
    end
end
