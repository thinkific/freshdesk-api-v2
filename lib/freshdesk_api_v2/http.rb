module FreshdeskApiV2
  class Http
    def initialize(configuration)
      @configuration = configuration
    end

    def get(path, headers = {})
      res = construct_http_client(path, default_headers.merge(headers))
      res.get
    end

    def delete(path, headers = {})
      res = construct_http_client(path, default_headers.merge(headers))
      res.delete
    end

    def put(path, attributes, headers = {})
      res = construct_http_client(path, default_headers.merge(headers))
      res.put(body: attributes.to_json)
    end

    def post(path, attributes, headers = {})
      res = construct_http_client(path, default_headers.merge(headers))
      res.post(body: attributes.to_json)
    end

    private

      def base_api_url
        "https://#{@configuration.domain}.freshdesk.com/api/v2"
      end

      def default_headers
        {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      end

      def password_or_x
        if @configuration.api_key.nil?
          @configuration.password
        else
          'X'
        end
      end

      def username_or_api_key
        if @configuration.api_key.nil?
          @configuration.username
        else
          @configuration.api_key
        end
      end

      def construct_http_client(path, headers)
        Excon.new("#{base_api_url}/#{path}",
          uri_parser: Addressable::URI,
          headers: headers,
          user: username_or_api_key,
          password: password_or_x
        )
      end
  end
end
