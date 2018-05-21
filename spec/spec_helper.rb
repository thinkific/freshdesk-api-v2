require 'bundler/setup'
require 'freshdesk_api_v2'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :all do
    Excon.defaults[:mock] = true
  end

  config.before do
    FreshdeskApiV2.configure do |conf|
      conf.domain = 'test-domain'
      conf.api_key = 'api-key'
    end
  end

  config.after do
    FreshdeskApiV2.reset_configuration!
    Excon.stubs.clear
  end
end
