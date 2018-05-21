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

    protected

      def endpoint
        'contacts'
      end

      def allowed_attributes
        ALLOWED_ATTRIBUTES
      end
  end
end
