module FreshdeskApiV2
  class ListOnlyBase
    def initialize(http)
      @http = http
    end

    def list
      fix_list_response(@http.get(endpoint))
    end

    protected

      # This method should be overridden in derived classes
      def endpoint
        raise StandardError, 'Please implement this method.'
      end

      def fix_list_response(response)
        altered_body = "{\"results\": #{response.body}}"
        response.body = altered_body
        response
      end
  end
end
