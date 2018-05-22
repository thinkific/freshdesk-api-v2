module FreshdeskApiV2
  class Base
    def initialize(http)
      @http = http
    end

    def list(pagination_options = {})
      per_page = pagination_options[:per_page] || Utils::MAX_PAGE_SIZE
      raise PaginationException, "Max per page is #{Utils::MAX_PAGE_SIZE}" if per_page.to_i > Utils::MAX_PAGE_SIZE
      first_page, last_page = extract_list_pagination(pagination_options)
      validate_list_pagination!(first_page, last_page)
      paginated_get(first_page, last_page, per_page)
    end

    # TODO - Note that queries that by email or things that have special characters to not work yet in
    # Freshdesk
    def search(query, pagination_options = {})
      raise SearchException, 'You must provide a query' if query.nil?
      raise SearchException, 'You must provide a query of type FreshdeskApiV2::SearchArgs' unless query.is_a?(FreshdeskApiV2::SearchArgs)
      raise SearchException, 'You must provide a query' unless query.valid?
      first_page, last_page = extract_search_pagination(pagination_options)
      validate_search_pagination!(first_page, last_page)
      paginated_search(query.to_query, first_page, last_page)
    end

    def show(id)
      get(id)
    end

    def create(attributes)
      validate_create_attributes!(attributes)
      attributes = prepare_attributes!(attributes)
      post(attributes)
    end

    def update(id, attributes)
      validate_update_attributes!(attributes)
      attributes = prepare_attributes!(attributes)
      put(id, attributes)
    end

    def destroy(id)
      delete(id)
    end

    protected

      # This method should be overridden in derived classes
      def endpoint
        raise StandardError, 'Please implement this method.'
      end

      # These methods can be overridden in derived classes
      def validate_create_attributes!(attributes)
        raise CreationException, 'Please provide attributes' if attributes.nil? || attributes.count == 0
      end

      def validate_update_attributes!(attributes)
        raise UpdateException, 'Please provide attributes' if attributes.nil? || attributes.count == 0
      end

      def validate_list_pagination!(first_page, last_page)
        raise PaginationException, 'first_page must be a number greater than 0' if first_page.to_i <= 0
        raise PaginationException, 'last_page must be a number greater than or equal to first_page' if last_page.to_i < first_page.to_i
      end

      def validate_search_pagination!(first_page, last_page)
        raise PaginationException, 'first_page must be a number greater than 0' if first_page.to_i <= 0
        unless last_page.nil?
          raise PaginationException, "last_page cannot exceed #{Utils::MAX_SEARCH_PAGES}" if last_page.to_i > Utils::MAX_SEARCH_PAGES
          raise PaginationException, 'last_page must be a number greater than or equal to first_page' if last_page.to_i < first_page.to_i
        end
      end

      def prepare_attributes!(attributes)
        clean = attributes.reject { |key, value | !allowed_attributes.include?(key) || value.nil? }
        custom_fields = clean['custom_fields']
        if !custom_fields.nil? && custom_fields.any?
          custom_fields = custom_fields.reject { |_, value| value.nil? }
          clean['custom_fields'] = custom_fields if !custom_fields.nil? && custom_fields.any?
        end
        clean
      end

    private

      def get(id)
        response = @http.get("#{api_url}/#{id}")
        JSON.parse(response.body)
      end

      def post(attributes)
        response = @http.post("#{api_url}", attributes)
        JSON.parse(response.body)
      end

      def delete(id)
        response = @http.delete("#{api_url}/#{id}")
        response.status
      end

      def put(id, attributes)
        response = @http.put("#{api_url}/#{id}", attributes)
        JSON.parse(response.body)
      end

      def paginated_get(first_page, last_page, per_page)
        url = "#{api_url}?page=#{first_page}&per_page=#{per_page}"
        @http.paginated_get(url, last_page)
      end

      # For example, see: https://developers.freshdesk.com/api/#filter_contacts
      def paginated_search(query, first_page, last_page)
        url = "#{base_api_url}/search/#{endpoint}?page=#{first_page}&query=#{query}"
        @http.paginated_search(url, last_page)
      end

      def extract_list_pagination(options)
        first_page = options[:first_page] || Utils::DEFAULT_PAGE
        last_page = options[:last_page] || Utils::INTEGER_MAX
        [first_page, last_page]
      end

      def extract_search_pagination(options)
        first_page = options[:first_page] || Utils::DEFAULT_PAGE
        last_page = options[:last_page]
        [first_page, last_page]
      end

      def base_api_url
        "https://#{@http.domain}.freshdesk.com/api/v2"
      end

      def api_url
        "#{base_api_url}/#{endpoint}"
      end
  end
end
