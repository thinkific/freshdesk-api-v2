module FreshdeskApiV2
  class SearchArgs
    def initialize
      @args = []
    end

    def valid?
      @args.length > 0
    end

    def add(field, value)
      @args << "#{field}:#{CGI::escape(value.to_s)}"
      self
    end

    def left_parenthesis
      @args << '('
      self
    end

    def right_parenthesis
      @args << ')'
      self
    end

    def and
      @args << ' AND '
      self
    end

    def or
      @args << ' OR '
      self
    end

    def to_query
      s = @args.join('')
      '"' + s + '"'
    end

    class << self
      def create(field, value)
        new().add(field, value)
      end
    end
  end
end
