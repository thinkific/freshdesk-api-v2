require 'addressable/uri'
require 'excon'
require 'uri'
require 'cgi'
require 'json'
require 'freshdesk_api_v2/version'
require 'freshdesk_api_v2/config'
require 'freshdesk_api_v2/exceptions'
require 'freshdesk_api_v2/search_args'
require 'freshdesk_api_v2/utils'
require 'freshdesk_api_v2/base'
require 'freshdesk_api_v2/list_only_base'
require 'freshdesk_api_v2/contacts'
require 'freshdesk_api_v2/companies'
require 'freshdesk_api_v2/contact_fields'
require 'freshdesk_api_v2/company_fields'
require 'freshdesk_api_v2/http'
require 'freshdesk_api_v2/client'

module FreshdeskApiV2
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
