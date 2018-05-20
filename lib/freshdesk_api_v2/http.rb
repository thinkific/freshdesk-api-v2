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
        url.gsub!("?page=#{current_page - 1}", "?page=#{current_page}")
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
      links = @link_parser.parse(response)
      collection += JSON.parse(response.body)
      while !links.nil? && links.by_rel('next')
        url = links.by_rel('next').target.to_s
        next_page = next_page(url)
        if next_page.to_i <= last_page.to_i
          response = get(url)
          links = @link_parser.parse(response)
          collection += JSON.parse(response.body)
        else
          links = nil
        end
      end
      collection
    end

    def get(url)
      res = construct_http_client(url, accept_headers)
      res.get
    end

    def delete(url)
      res = construct_http_client(url, accept_headers)
      res.delete
    end

    def put(url, attributes)
      res = construct_http_client(url, content_type_headers)
      res.put(attributes.to_json)
    end

    def post(url, attributes)
      res = construct_http_client(url, content_type_headers)
      res.post(attributes.to_json)
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
        results = payload['results']
        if results.nil? && response.status == 400
          error_desc = payload['description']
          errors = payload['errors']
          raise InvalidSearchException.new(error_desc, errors)
        end
        [page_count, results]
      end

      def next_page(url)
        url[Utils::PAGE_REGEX, 1]
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

      def construct_http_client(url, headers)
        Excon.new(url,
          uri_parser: Addressable::URI,
          headers: headers,
          user: username_or_api_key,
          password: password_or_x
        )
      end
  end
end
