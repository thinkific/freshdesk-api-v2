module FreshdeskApiV2
  class Http
    PAGE_REGEX = /.*[\?\&]page=(\d)*.*/

    def initialize(configuration)
      @configuration = configuration
      @link_parser = Nitlink::Parser.new
    end

    def paginate(url, last_page, collection = [])
      response = get(url)
      collection += JSON.parse(response.body)
      links = @link_parser.parse(response)
      while !links.nil? && links.by_rel('next')
        url = links.by_rel('next').target.to_s
        next_page = next_page(url)
        if next_page.to_i <= last_page.to_i
          response = get(url)
          collection += JSON.parse(response.body)
          links = @link_parser.parse(response)
        else
          links = nil
        end
      end
      collection
    end

    def get(url)
      res = construct_rest_client(url)
      res.get(accept_headers)
    end

    def delete(url)
      res = construct_rest_client(url)
      res.delete(accept_headers)
    end

    def put(url, attributes)
      res = construct_rest_client(url)
      res.put(attributes.to_json, content_type_headers)
    end

    def post(url, attributes)
      res = construct_rest_client(url)
      res.post(attributes.to_json, content_type_headers)
    end

    def domain
      @configuration.domain
    end

    private

      def next_page(url)
        url[PAGE_REGEX, 1]
      end

      def accept_headers
        { accept: 'application/json' }
      end

      def content_type_headers
        { content_type: 'application/json' }
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

      def construct_rest_client(url)
        RestClient::Resource.new(url, username_or_api_key, password_or_x)
      end
  end
end
