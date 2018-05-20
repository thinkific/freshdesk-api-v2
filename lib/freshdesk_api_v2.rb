require 'freshdesk_api_v2/version'
require 'config'
require 'addressable/uri'
require 'excon'
require 'nitlink'
require 'uri'
require 'cgi'
require 'json'
require 'freshdesk_api_v2/search_args'
require 'freshdesk_api_v2/utils'
require 'freshdesk_api_v2/entity'
require 'freshdesk_api_v2/contacts'
require 'freshdesk_api_v2/companies'
require 'freshdesk_api_v2/contact_fields'
require 'freshdesk_api_v2/company_fields'
require 'freshdesk_api_v2/http'
require 'freshdesk_api_v2/client'

module FreshdeskApiV2
  class ConfigurationException < StandardError; end
  class PaginationException < StandardError; end
  class SearchException < StandardError; end
  class CreationException < StandardError; end
  class UpdateException < StandardError; end

  class InvalidSearchException < StandardError
    attr_reader :errors
    def initialize(error_description, errors)
      super(error_description)
      @errors = errors
    end
  end

  def self.configure(&block)
    @config = Config.new
    block.call(@config)
  end

  def self.reset_configuration!
    @config = nil
  end

  def self.configuration
    @config || Config.new
  end
end
