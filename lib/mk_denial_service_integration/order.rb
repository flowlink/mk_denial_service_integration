module MKDenialServiceIntegration
  class Order
    attr_reader :config, :billing_address, :shipping_address

    def initialize(config, payload)
      @config = config
      @billing_address = payload[:order][:billing_address]
      @shipping_address = payload[:order][:shipping_address]
    end

    def verify!
      result = denial_service.search_dpl groups
      if hits = result[:search_dpl_response][:search_dpl_result][:hits]
        if hits[:dp_lv3_1_entry].is_a?(Array)
          hits[:dp_lv3_1_entry]
        else
          [hits[:dp_lv3_1_entry]]
        end
      end
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
