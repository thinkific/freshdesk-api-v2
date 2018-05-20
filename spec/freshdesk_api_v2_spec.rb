RSpec.describe FreshdeskApiV2 do
  it 'has a version number' do
    expect(FreshdeskApiV2::VERSION).not_to be nil
  end

  it 'can be configured' do
    expect(FreshdeskApiV2).to respond_to(:configure)
  end

  it 'tests things' do
    # config = FreshdeskApiV2::Config.new
    # config.domain = 'thinkificdev'
    # config.api_key = 'Q18WiF1ToJM3qRnzroX'
    # client = FreshdeskApiV2::Client.new(config)
    # companies = client.companies.list(first_page: 1, last_page: 3)
  end
end
