module FreshdeskApiV2
  class Companies < Base
    ALLOWED_ATTRIBUTES = %w[
      custom_fields
      description
      domains
      name
      note
      health_score
      account_tier
      renewal_date
      industry
    ].freeze

    protected

      def endpoint
        'companies'
      end

      def allowed_attributes
        ALLOWED_ATTRIBUTES
      end
  end
end
