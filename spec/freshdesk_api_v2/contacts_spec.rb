RSpec.describe FreshdeskApiV2::Contacts do
  let(:http) do
    config = FreshdeskApiV2::Config.new(domain: 'test', api_key: 'key')
    FreshdeskApiV2::Http.new(config)
  end

  let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }

  subject { FreshdeskApiV2::Contacts.new(http) }

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
    let(:contacts) do
      [
        contact_attributes(id: 1, name: 'Bob Jones'),
        contact_attributes(id: 2, name: 'Jim Smith')
      ]
    end

    it 'returns a list of contacts' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/contacts',
          headers: headers
        },
        {
          body: contacts.to_json,
          status: 200
        }
      )
      response = subject.list
      expect(JSON.parse(response.body)).to be_instance_of(Array)
    end

    it 'filters on any supplied filters' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/contacts',
          query: 'email=test%40example.com&name=monkey',
          headers: headers
        },
        {
          body: contacts.to_json,
          status: 200
        }
      )
      response = subject.list(filters: { email: 'test@example.com', name: 'monkey' })
      expect(JSON.parse(response.body)).to be_instance_of(Array)
    end

    it 'applies pagination' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/contacts',
          query: 'page=2&per_page=50',
          headers: headers
        },
        {
          body: contacts.to_json,
          status: 200
        }
      )
      response = subject.list(page: 2, per_page: 50)
      expect(JSON.parse(response.body)).to be_instance_of(Array)
    end

    it "raises an exception when per_page is greater than #{FreshdeskApiV2::Utils::MAX_LIST_PER_PAGE}" do
      expect do
        subject.list(first_page: 1, per_page: FreshdeskApiV2::Utils::MAX_LIST_PER_PAGE + 1)
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end
  end

  context 'search' do
    let(:query) { FreshdeskApiV2::SearchArgs.create('name', 'Bob') }
    let(:contacts) do
      [
        contact_attributes(id: 1, name: 'Bob Jones'),
        contact_attributes(id: 2, name: 'Jim Smith')
      ]
    end

    it 'returns a list of contacts matching the query' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/search/contacts',
          query: 'query="name:Bob"',
          headers: headers
        },
        {
          body: contacts.to_json,
          status: 200
        }
      )
      response = subject.search(query)
      expect(JSON.parse(response.body)).to be_instance_of(Array)
    end

    it 'returns a list of contacts matching the query and page' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/search/contacts',
          query: 'page=2&query="name:Bob"',
          headers: headers
        },
        {
          body: contacts.to_json,
          status: 200
        }
      )
      response = subject.search(query, page: 2)
      expect(JSON.parse(response.body)).to be_instance_of(Array)
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
    let(:contact_response) { contact_attributes(id: 1) }

    it 'returns the contact' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/contacts/1',
          headers: headers
        },
        {
          body: contact_response.to_json,
          status: 200
        }
      )
      expect(JSON.parse(subject.get(1).body)).not_to be_nil
    end
  end

  context 'destroy' do
    let(:contact_response) { contact_attributes(id: 1) }

    before do
      Excon.stub(
        {
          method: :delete,
          path: '/api/v2/contacts/1',
          headers: headers
        },
        {
          body: contact_response.to_json,
          status: 204
        }
      )
    end

    it 'returns a status code of 204' do
      expect(subject.destroy(1).status).to eq(204)
    end
  end

  context 'create' do
    let(:contact_response) { contact_attributes(id: 1) }

    before do
      Excon.stub(
        {
          method: :post,
          path: '/api/v2/contacts',
          headers: headers,
          body: contact_attributes.to_json
        },
        {
          body: contact_response.to_json,
          status: 201
        }
      )
    end

    it 'returns the new contact' do
      response = subject.create(contact_attributes)
      expect(response).not_to be_nil
    end

    it 'filters out non-whitelisted properties' do
      subject.create(contact_attributes(monkey: 'Yes'))
    end

    it 'filters out nil properties' do
      altered_attributes = contact_attributes.dup
      altered_attributes.delete(:description)
      Excon.stub(
        {
          method: :post,
          path: '/api/v2/contacts',
          headers: headers,
          body: altered_attributes.to_json
        },
        {
          body: contact_response.to_json
        }
      )
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
    let(:contact_response) { contact_attributes(id: 1) }

    before do
      Excon.stub(
        {
          method: :put,
          path: '/api/v2/contacts/1',
          headers: headers,
          body: contact_attributes.to_json
        },
        {
          body: contact_response.to_json,
          status: 201
        }
      )
    end

    it 'returns the updated contact' do
      response = subject.update(1, contact_attributes)
      expect(response).not_to be_nil
    end

    it 'filters out non-whitelisted properties' do
      subject.update(1, contact_attributes(monkey: 'Yes'))
    end

    it 'filters out nil properties' do
      altered_attributes = contact_attributes.dup
      altered_attributes.delete(:description)
      Excon.stub(
        {
          method: :put,
          path: '/api/v2/contacts/1',
          headers: headers,
          body: altered_attributes.to_json
        },
        {
          body: contact_response.to_json
        }
      )
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
