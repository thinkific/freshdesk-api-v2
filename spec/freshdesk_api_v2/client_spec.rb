RSpec.describe FreshdeskApiV2::Client do
  subject do
    FreshdeskApiV2::Client.new
  end

  it 'can be constructed from defaults' do
    client = FreshdeskApiV2::Client.new
    expect(client.configuration.domain).to eq(FreshdeskApiV2.configuration.domain)
    expect(client.configuration.api_key).to eq(FreshdeskApiV2.configuration.api_key)
  end

  it 'can be constructed from a hash of settings' do
    client = FreshdeskApiV2::Client.new(domain: 'domain', api_key: 'api_key')
    expect(client.configuration.domain).to eq('domain')
    expect(client.configuration.api_key).to eq('api_key')
  end

  it 'can be constructed from a FreshdeskApiV2::Config object' do
    config = FreshdeskApiV2::Config.new(domain: 'domain', api_key: 'api_key')
    client = FreshdeskApiV2::Client.new(config)
    expect(client.configuration.domain).to eq('domain')
    expect(client.configuration.api_key).to eq('api_key')
  end

  it 'responds to contacts with a Contacts object' do
    expect(subject.contacts).to be_instance_of(FreshdeskApiV2::Contacts)
  end

  it 'responds to companies with a Companies object' do
    expect(subject.companies).to be_instance_of(FreshdeskApiV2::Companies)
  end

  it 'responds to contact_fields with a ContactFields object' do
    expect(subject.contact_fields).to be_instance_of(FreshdeskApiV2::ContactFields)
  end

  it 'responds to the company_fields with a CompanyFields object' do
    expect(subject.company_fields).to be_instance_of(FreshdeskApiV2::CompanyFields)
  end
end
