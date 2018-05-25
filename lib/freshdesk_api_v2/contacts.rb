module FreshdeskApiV2
  class Contacts < Base
    ALLOWED_ATTRIBUTES = [
      :name,
      :phone,
      :email,
      :mobile,
      :twitter_id,
      :unique_external_id,
      :other_emails,
      :company_id,
      :view_all_tickets,
      :other_companies,
      :address,
      :avatar,
      :custom_fields,
      :description,
      :job_title,
      :tags,
      :timezone
    ].freeze

    # options:
    # => page: integer > 0
    # => per_page: integer > 0 && <= 100
    # => filters: hash of key value pairs
    def list(options = {})
      page = options[:page]
      per_page = options[:per_page]
      filters = options[:filters]
      validate_list_pagination!(page, per_page)
      qs = pagination_query_string(page: page, per_page: per_page)
      if !filters.nil? && filters.any?
        filter_qs = filter_query_string(filters)
        qs = qs.length > 0 ? "#{qs}&#{filter_qs}" : filter_qs
      end
      url = qs.length > 0 ? "#{endpoint}?#{qs}" : endpoint
      @http.get(url)
    end

    protected

      def endpoint
        'contacts'
      end

      def allowed_attributes
        ALLOWED_ATTRIBUTES
      end

    private

      def filter_query_string(filters)
        filters.map { |key, value| "#{key}=#{CGI::escape(value.to_s)}"}.join('&')
      end
  end
end
