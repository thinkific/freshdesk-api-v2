require 'freshdesk_api_v2/version'
require 'config'
require 'rest-client'
require 'nitlink'
require 'uri'
require 'json'
require 'freshdesk_api_v2/utils'
require 'freshdesk_api_v2/entity'
require 'freshdesk_api_v2/contacts'
require 'freshdesk_api_v2/companies'
require 'freshdesk_api_v2/http'
require 'freshdesk_api_v2/client'

module FreshdeskApiV2
  class ConfigurationException < StandardError; end
  class PaginationException < StandardError; end
  class SearchException < StandardError; end
  class CreationException < StandardError; end
  class UpdateException < StandardError; end

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
