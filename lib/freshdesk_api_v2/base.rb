module FreshdeskApiV2
  class Base
    def initialize(http)
      @http = http
    end

    # pagination_options: page: integer > 0, per_page: integer > 0 && <= 100
    def list(pagination_options = {})
      page = pagination_options[:page]
      per_page = pagination_options[:per_page]
      validate_list_pagination!(page, per_page)
      qs = pagination_query_string(page: page, per_page: per_page)
      url = qs.length > 0 ? "#{endpoint}?#{qs}" : endpoint
      fix_list_response(@http.get(url))
    end

    # TODO - Note that some 'filters' (contacts by email, for example) do not work yet in
    # Freshdesk. This appears to be a bug on their side.
    # query: An instance of FreshdeskApiV2::SearchArgs
    # pagination_options: page: integer > 0
    def search(query, pagination_options = {})
      validate_search_query!(query)
      page = pagination_options[:page]
      validate_search_pagination!(page)
      qs = pagination_query_string(page: page)
      url = qs.length > 0 ? "search/#{endpoint}?#{qs}&query=#{query.to_query}" : "search/#{endpoint}?query=#{query.to_query}"
      @http.get(url)
    end

    def get(id)
      @http.get("#{endpoint}/#{id}")
    end

    def create(attributes)
      validate_create_attributes!(attributes)
      attributes = prepare_attributes!(attributes)
      @http.post(endpoint, attributes)
    end

    def update(id, attributes)
      validate_update_attributes!(attributes)
      attributes = prepare_attributes!(attributes)
      @http.put("#{endpoint}/#{id}", attributes)
    end

    def destroy(id)
      @http.delete("#{endpoint}/#{id}")
    end

    protected

      def pagination_query_string(hash)
        hash.reject { |_, value| value.nil? }
          .map { |key, value| "#{key}=#{value}"}
          .join('&')
      end

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

      # rubocop:disable CyclomaticComplexity
      def validate_list_pagination!(page, per_page)
        return if page.nil? && per_page.nil?
        raise PaginationException, 'page must be a number greater than 0' if !page.nil? && page.to_i <= 0
        raise PaginationException, 'per_page must be a number greater than 0' if !per_page.nil? && per_page.to_i <= 0
        raise PaginationException, "per_page must be a number less than or equal to #{Utils::MAX_LIST_PER_PAGE}" if !per_page.nil? && per_page.to_i > Utils::MAX_LIST_PER_PAGE
      end

      def validate_search_pagination!(page)
        raise PaginationException, 'page must be a number greater than 0' if !page.nil? && page.to_i <= 0
        raise PaginationException, "page must be less than or equal to #{Utils::MAX_SEARCH_PAGES}" if !page.nil? && page.to_i > Utils::MAX_SEARCH_PAGES
      end

      def prepare_attributes!(attributes)
        clean = attributes.reject { |key, value | !allowed_attributes.include?(key.to_sym) || value.nil? }
        custom_fields = clean['custom_fields']
        if !custom_fields.nil? && custom_fields.any?
          custom_fields = custom_fields.reject { |_, value| value.nil? }
          clean['custom_fields'] = custom_fields if !custom_fields.nil? && custom_fields.any?
        end
        clean
      end

      def validate_search_query!(query)
        raise SearchException, 'You must provide a query' if query.nil?
        raise SearchException, 'You must provide a query of type FreshdeskApiV2::SearchArgs' unless query.is_a?(FreshdeskApiV2::SearchArgs)
        raise SearchException, 'You must provide a query' unless query.valid?
      end

      def fix_list_response(response)
        altered_body = "{\"results\": #{response.body}}"
        response.body = altered_body
        response
      end
  end
end
