module FreshdeskApiV2
  class Client
    attr_reader :configuration

    def initialize(configuration = nil)
      if !configuration.nil?
        @configuration = Config.new(configuration) if configuration.is_a?(Hash)
        @configuration = configuration if configuration.is_a?(FreshdeskApiV2::Config)
      else
        @configuration = FreshdeskApiV2.configuration
      end
      @configuration.validate!
      @http = Http.new(@configuration)
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
