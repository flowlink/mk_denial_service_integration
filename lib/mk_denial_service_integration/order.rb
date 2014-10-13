module MKDenialServiceIntegration
  class Order
    attr_reader :config, :payload, :billing_address, :shipping_address

    def initialize(config, payload)
      @config = config
      @payload = payload
      @billing_address = payload[:order][:billing_address]
      @shipping_address = payload[:order][:shipping_address]
    end

    def updated_object
      {
        id: payload[:order][:id],
        mkd_hits: hits,
        mkd_screen_result: mkd_screen_result
      }
    end

    def mkd_screen_result(collection = hits)
      screen_result = (collection || []).any? do |hit|
        end_date = Time.parse hit[:end_date].to_s
        end_date >= Time.now
      end

      screen_result ? "denied" : "approved"
    end

    def hits
      if hits = result[:search_dpl_response][:search_dpl_result][:hits]
        if hits[:dp_lv3_1_entry].is_a?(Array)
          hits[:dp_lv3_1_entry]
        else
          [hits[:dp_lv3_1_entry]]
        end
      end
    end

    def result
      @result ||= denial_service.search_dpl groups
    end

    def groups
      if billing_address == shipping_address
        [denial_service.build_group(billing_address)]
      else
        [billing_address, shipping_address].map do |address|
          denial_service.build_group address
        end
      end
    end

    private
      def denial_service
        @denial_service ||= MKDenialService.new config
      end
  end
end
