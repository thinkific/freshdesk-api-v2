module FreshdeskApiV2
  class ListOnlyBase
    def initialize(http)
      @http = http
    end

    def list
      response = @http.get(api_url)
      JSON.parse(response.body)
    end

    protected

      # This method should be overridden in derived classes
      def endpoint
        raise StandardError, 'Please implement this method.'
      end

    private

      def base_api_url
        "https://#{@http.domain}.freshdesk.com/api/v2"
      end

      def api_url
        "#{base_api_url}/#{endpoint}"
      end
  end
end
