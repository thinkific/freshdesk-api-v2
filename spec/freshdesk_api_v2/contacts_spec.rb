require 'byebug'
RSpec.describe FreshdeskApiV2::Contacts do
  before do
    @mock_http = double('Mock HTTP', domain: 'test')
  end

  subject { FreshdeskApiV2::Contacts.new(@mock_http) }

  def contact_attributes(overrides = {})
    {
      name: 'Bob Smith',
      phone: '778-987-9090',
      email: 'bob@example.com',
      mobile: '778-980-9090',
      twitter_id: '',
      unique_external_id: 'ext_id',
      other_emails: [],
      company_id: 1_234_567,
      view_all_tickets: true,
      other_companies: ['Company A', 'Company B'],
      address: '123 Test St.',
      avatar: '',
      custom_fields: { first_name: 'Bob', last_name: 'Smith' },
      description: 'Descr',
      job_title: 'Owner',
      tags: %w[A B],
      timezone: 'PST'
    }.merge(overrides)
  end

  context 'list' do
    let(:contacts) { double('HTTP Response', body: [contact_attributes(id: 1, name: 'Bob Jones'), contact_attributes(id: 2, name: 'Jim Smith')].to_json) }

    before do
      allow(@mock_http).to receive(:get).and_return(contacts)
    end

    it 'returns a list of contacts' do
      expect(JSON.parse(subject.list.body)).to be_instance_of(Array)
    end

    it "raises an exception when per_page is greater than #{FreshdeskApiV2::Utils::MAX_LIST_PER_PAGE}" do
      expect do
        subject.list(first_page: 1, per_page: FreshdeskApiV2::Utils::MAX_LIST_PER_PAGE + 1)
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end
  end

  context 'search' do
    let(:query) { FreshdeskApiV2::SearchArgs.create('name', 'Bob') }
    let(:contacts) { double('HTTP Response', body: [contact_attributes(id: 1, name: 'Bob Jones'), contact_attributes(id: 2, name: 'Jim Smith')].to_json) }

    before do
      allow(@mock_http).to receive(:get).and_return(contacts)
    end

    it 'returns a list of contacts matching the query' do
      expect(JSON.parse(subject.search(query).body)).to be_instance_of(Array)
    end

    it 'raises an exception when a query is not given' do
      expect do
        subject.search(nil)
      end.to raise_error(FreshdeskApiV2::SearchException)
    end

    it 'raises an exception when the query given is invalid' do
      q = FreshdeskApiV2::SearchArgs.new
      expect do
        subject.search(q)
      end.to raise_error(FreshdeskApiV2::SearchException)
    end

    it "raises an exception when page is greater than #{FreshdeskApiV2::Utils::MAX_SEARCH_PAGES}" do
      expect do
        subject.search(query, page: FreshdeskApiV2::Utils::MAX_SEARCH_PAGES + 1)
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end

  end

  context 'get' do
    let(:response) { double('Mock HTTP Response', body: contact_attributes.to_json) }

    before do
      allow(@mock_http).to receive(:get).and_return(response)
    end

    it 'returns the contact' do
      expect(JSON.parse(subject.get(1).body)).not_to be_nil
    end
  end

  context 'destroy' do
    let(:response) { double('Mock HTTP Response', body: contact_attributes.to_json, status: 204) }

    before do
      allow(@mock_http).to receive(:delete).and_return(response)
    end

    it 'deletes the contact' do
      expect(@mock_http).to receive(:delete).and_return(response)
      subject.destroy(1)
    end

    it 'returns a status code of 204' do
      expect(subject.destroy(1).status).to eq(204)
    end
  end

  context 'create' do
    let(:endpoint) { 'contacts' }
    let(:response) { double('Mock HTTP Response', body: contact_attributes.to_json) }

    before do
      allow(@mock_http).to receive(:post).and_return(response)
    end

    it 'creates the contact' do
      expect(@mock_http).to receive(:post).with(endpoint, contact_attributes).and_return(response)
      subject.create(contact_attributes)
    end

    it 'returns the contact' do
      response = subject.create(contact_attributes)
      expect(response).not_to be_nil
    end

    it 'filters out non-whitelisted properties' do
      expect(@mock_http).to receive(:post).with(endpoint, contact_attributes)
      subject.create(contact_attributes(monkey: 'Yes'))
    end

    it 'filters out nil properties' do
      altered_attributes = contact_attributes.dup
      altered_attributes.delete(:description)
      expect(@mock_http).to receive(:post).with(endpoint, altered_attributes)
      subject.create(contact_attributes(description: nil))
    end

    it 'raises an exception when no attributes are given' do
      expect do
        subject.create(nil)
      end.to raise_error(FreshdeskApiV2::CreationException)
    end

    it 'raises an exception when empty attributes are given' do
      expect do
        subject.create({})
      end.to raise_error(FreshdeskApiV2::CreationException)
    end
  end

  context 'update' do
    let(:endpoint) { 'contacts/1' }
    let(:response) { double('Mock HTTP Response', body: contact_attributes(id: 1).to_json) }

    before do
      allow(@mock_http).to receive(:put).and_return(response)
    end

    it 'updates the contact' do
      expect(@mock_http).to receive(:put).with(endpoint, contact_attributes).and_return(response)
      subject.update(1, contact_attributes)
    end

    it 'returns the contact' do
      response = subject.update(1, contact_attributes)
      expect(response).not_to be_nil
    end

    it 'filters out non-whitelisted properties' do
      expect(@mock_http).to receive(:put).with(endpoint, contact_attributes)
      subject.update(1, contact_attributes(monkey: 'Yes'))
    end

    it 'filters out nil properties' do
      altered_attributes = contact_attributes.dup
      altered_attributes.delete(:description)
      expect(@mock_http).to receive(:put).with(endpoint, altered_attributes)
      subject.update(1, contact_attributes(description: nil))
    end

    it 'raises an exception when no attributes are given' do
      expect do
        subject.update(1, nil)
      end.to raise_error(FreshdeskApiV2::UpdateException)
    end

    it 'raises an exception when empty attributes are given' do
      expect do
        subject.update(1, {})
      end.to raise_error(FreshdeskApiV2::UpdateException)
    end
  end
end
