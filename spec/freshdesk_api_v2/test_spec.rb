RSpec.describe 'Testing' do
  before do
    FreshdeskApiV2.configure do |conf|
      conf.domain = 'thinkificdev'
      conf.api_key = 'Q18WiF1ToJM3qRnzroX'
    end
    @client = FreshdeskApiV2::Client.new
  end

  it 'tests' do
    # @client.contacts.list(first_page: 1, last_page: 2, per_page: 10)
    # @client.contacts.show(9019726429)
    # c = @client.contacts.create(
    #   name: "New API Test",
    #   email: "matt.payne+new_api@thinkific.com",
    #   unique_external_id: 'abc123'
    # )
  end
end
