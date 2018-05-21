module FreshdeskApiV2
  class Base
    def initialize(http)
      @http = http
    end

    def list(options = {})
      per_page = value_from_options(options, :per_page) || Utils::MAX_PAGE_SIZE
      raise PaginationException, "Max per page is #{Utils::MAX_PAGE_SIZE}" if per_page.to_i > Utils::MAX_PAGE_SIZE
      first_page, last_page = extract_pagination(options)
      validate_pagination!(first_page, last_page)
      http_list(first_page, last_page, per_page)
    end

    # TODO - Note that queries that by email or things that have special characters to not work yet in
    # Freshdesk
    def search(query, options = {})
      raise SearchException, 'You must provide a query' if query.nil?
      raise SearchException, 'You must provide a query of type FreshdeskApiV2::SearchArgs' unless query.is_a?(FreshdeskApiV2::SearchArgs)
      raise SearchException, 'You must provide a query' unless query.valid?
      first_page, last_page = extract_pagination(options)
      validate_pagination!(first_page, last_page)
      http_search(query.to_query, first_page, last_page)
    end

    def show(id)
      http_show(id)
    end

    def create(attributes)
      validate_create_attributes!(attributes)
      attributes = prepare_attributes!(attributes)
      http_create(attributes)
    end

    def update(id, attributes)
      validate_update_attributes!(attributes)
      attributes = prepare_attributes!(attributes)
      http_update(id, attributes)
    end

    def destroy(id)
      http_destroy(id)
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

      def validate_pagination!(first_page, last_page)
        raise PaginationException, 'first_page must be a number greater than 0' if first_page.to_i <= 0
        raise PaginationException, 'last_page must be a number greater than or equal to first_page' if last_page.to_i < first_page.to_i
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

      def http_show(id)
        response = @http.get("#{api_url}/#{id}")
        JSON.parse(response.body)
      end

      def http_create(attributes)
        response = @http.post("#{api_url}", attributes)
        JSON.parse(response.body)
      end

      def http_destroy(id)
        response = @http.delete("#{api_url}/#{id}")
        response.status
      end

      def http_update(id, attributes)
        response = @http.put("#{api_url}/#{id}", attributes)
        JSON.parse(response.body)
      end

      def http_list(first_page, last_page, per_page)
        url = "#{api_url}?page=#{first_page}&per_page=#{per_page}"
        @http.paginate(url, last_page)
      end

      # For example, see: https://developers.freshdesk.com/api/#filter_contacts
      def http_search(query, first_page, last_page)
        url = "#{base_api_url}/search/#{endpoint}?page=#{first_page}&query=#{query}"
        @http.search_paginate(url, last_page)
      end

      def extract_pagination(options)
        first_page = value_from_options(options, :first_page)
        last_page = value_from_options(options, :last_page)
        first_page ||= Utils::DEFAULT_PAGE
        last_page ||= Utils::INTEGER_MAX
        [first_page, last_page]
      end

      def value_from_options(options, key)
        options[key.to_s] || options[key.to_sym]
      end

      def base_api_url
        "https://#{@http.domain}.freshdesk.com/api/v2"
      end

      def api_url
        "#{base_api_url}/#{endpoint}"
      end
  end
end
