module FreshdeskApiV2
  class ListOnlyBase
    def initialize(http)
      @http = http
    end

    def list
      @http.get(endpoint)
    end

    protected

      # This method should be overridden in derived classes
      def endpoint
        raise StandardError, 'Please implement this method.'
      end
  end
end
