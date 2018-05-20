module FreshdeskApiV2
  class Client
    def initialize(configuration = nil)
      configuration = FreshdeskApiV2.configuration if configuration.nil?
      configuration.validate!
      @http = Http.new(configuration)
    end

    def contacts
      FreshdeskApiV2::Contacts.new(@http)
    end

    def contact_fields
      FreshdeskApiV2::ContactFields.new(@http)
    end

    def company_fields
      FreshdeskApiV2::CompanyFields.new(@http)
    end

    def companies
      FreshdeskApiV2::Companies.new(@http)
    end
  end
end
