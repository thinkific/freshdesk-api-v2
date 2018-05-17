RSpec.describe FreshdeskApiV2::Client do
  let(:api_key) { 'key' }
  let(:domain) { 'test-domain' }

  before do
    FreshdeskApiV2.configure do |conf|
      conf.domain = domain
      conf.api_key = api_key
    end
  end

  after do
    FreshdeskApiV2.reset_configuration!
  end

  subject do
    FreshdeskApiV2::Client.new
  end

  it 'responds to the contacts with a Contacts object' do
    expect(subject.contacts).to be_instance_of(FreshdeskApiV2::Contacts)
  end

  it 'responds to the companies with a Companies object' do
    expect(subject.companies).to be_instance_of(FreshdeskApiV2::Companies)
  end
end
