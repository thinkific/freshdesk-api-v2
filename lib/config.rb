module FreshdeskApiV2
  class Config
    attr_accessor :domain, :api_key, :username, :password

    def validate!
      validate_domain!
      validate_credentials!
    end

    private

      def validate_domain!
        if domain.nil? || domain.to_s.length == 0
          raise ConfigurationException, 'Domain is required.'
        end
      end

      def validate_credentials!
        raise ConfigurationException, 'Either an API key or username & password are required.' if none_present?(api_key, username, password)
        raise ConfigurationException, 'Please provide either an API key or a username & password, but not both.' if all_present?(api_key, username, password)
        validate_username_password! if none_present?(api_key)
      end

      def validate_username_password!
        raise ConfigurationException, 'Username and password are both required.' if any_nil_or_empty?(username, password)
      end

      def all_present?(*values)
        values.all? { |v| !v.nil? && v.to_s.strip.length > 0 }
      end

      def none_present?(*values)
        values.all? { |v| v.nil? || v.to_s.strip.length == 0 }
      end

      def any_nil_or_empty?(*values)
        values.any? { |v| v.nil? || v.to_s.strip.length == 0 }
      end
  end
end
