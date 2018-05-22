RSpec.describe FreshdeskApiV2::Config do
  let(:api_key) { 'key' }
  let(:domain) { 'test' }
  let(:username) { 'bob' }
  let(:password) { 'password' }

  subject { FreshdeskApiV2::Config.new }

  context 'validate!' do
    it 'should not raise an exception if domain and api_key are set' do
      subject.api_key = api_key
      subject.domain = domain
      expect { subject.validate! }.not_to raise_error
    end

    it 'should not raise an exception if domain, username and password are set' do
      subject.username = username
      subject.password = password
      subject.domain = domain
      expect { subject.validate! }.not_to raise_error
    end

    it 'should raise an exception if domain is not set' do
      subject.api_key = api_key
      expect { subject.validate! }.to raise_error(FreshdeskApiV2::ConfigurationException)
    end

    it 'should raise an exception if api_key, username and password are all set' do
      subject.domain = domain
      subject.api_key = api_key
      subject.username = username
      subject.password = password
      expect { subject.validate! }.to raise_error(FreshdeskApiV2::ConfigurationException)
    end

    it 'should raise an exception if username is set but password is not' do
      subject.domain = domain
      subject.username = username
      expect { subject.validate! }.to raise_error(FreshdeskApiV2::ConfigurationException)
    end

    it 'should raise an exception if password is set but username is not' do
      subject.domain = domain
      subject.password = password
      expect { subject.validate! }.to raise_error(FreshdeskApiV2::ConfigurationException)
    end
  end
end
