module FreshdeskApiV2
  class Http
    def initialize(configuration)
      @configuration = configuration
      @link_parser = Nitlink::Parser.new
    end

    # Freshdesk's search API uses a different pagination mechanism than their
    # regular pagination mechanism, so this implementation needs to be different.
    def search_paginate(url, last_page, collection = [])
      current_page = 1
      page_count, items = do_search(url)
      collection += items
      return collection if page_count == 1
      loop do
        current_page += 1
        # Freshdesk will only return up to a maximum of 10 pages, so
        # kill the loop if we get that far OR if we hit the last requested page
        break if current_page > Utils::MAX_SEARCH_PAGES || current_page > last_page
        url.gsub!("?page=#{page - 1}", "?page=#{page}")
        _, items = do_search(url)
        collection += items
        break if current_page > page_count
      end
      collection
    end

    # This is Freshdesk's normal pagination. It always returns a link to the next
    # page in a header called 'link' with a rel of 'next'
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

      def do_search(url)
        response = get(url)
        payload = JSON.parse(response.body)
        total = (payload['total'] || 0).to_f
        if total > Utils::MAX_SEARCH_RESULTS_PER_PAGE
          page_count = (total / Utils::MAX_SEARCH_RESULTS_PER_PAGE).ceil
        else
          page_count = 1
        end
        [page_count, payload['results']]
      end

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
