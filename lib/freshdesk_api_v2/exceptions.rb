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
end
