RSpec.describe FreshdeskApiV2::Companies do
  let(:http) do
    config = FreshdeskApiV2::Config.new(domain: 'test', api_key: 'key')
    FreshdeskApiV2::Http.new(config)
  end

  let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }

  subject { FreshdeskApiV2::Companies.new(http) }

  def company_attributes(overrides = {})
    {
      custom_fields: { name: 1 },
      description: 'A company',
      domains: ['test.company.com'],
      name: 'A Company',
      note: '',
      health_score: 'A',
      account_tier: 'Silver',
      renewal_date: '2019-01-01',
      industry: 'Stuff'
    }.merge(overrides)
  end

  context 'list' do
    let(:companies) do
      [
        company_attributes(id: 1, name: 'Company A'),
        company_attributes(id: 2, name: 'Company B')
      ]
    end

    it 'returns a list of companies' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/companies',
          headers: headers
        },
        {
          body: companies.to_json,
          status: 200
        }
      )
      response = subject.list
      expect(JSON.parse(response.body)).to be_instance_of(Array)
    end

    it 'applies pagination' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/companies',
          query: 'page=2&per_page=50',
          headers: headers
        },
        {
          body: companies.to_json,
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
    let(:query) { FreshdeskApiV2::SearchArgs.create('name', 'Exon') }
    let(:companies) do
      [
        company_attributes(id: 1, name: 'Company A'),
        company_attributes(id: 2, name: 'Company B')
      ]
    end

    it 'returns a list of companies matching the query' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/search/companies',
          query: 'query="name:Exon"',
          headers: headers
        },
        {
          body: companies.to_json,
          status: 200
        }
      )
      response = subject.search(query)
      expect(JSON.parse(response.body)).to be_instance_of(Array)
    end

    it 'returns a list of companies matching the query and page' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/search/companies',
          query: 'page=2&query="name:Exon"',
          headers: headers
        },
        {
          body: companies.to_json,
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
    let(:company_response) { company_attributes(id: 1) }

    it 'returns the contact' do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/companies/1',
          headers: headers
        },
        {
          body: company_response.to_json,
          status: 200
        }
      )
      expect(JSON.parse(subject.get(1).body)).not_to be_nil
    end
  end

  context 'destroy' do
    let(:company_response) { company_attributes(id: 1) }

    before do
      Excon.stub(
        {
          method: :delete,
          path: '/api/v2/companies/1',
          headers: headers
        },
        {
          body: company_response.to_json,
          status: 204
        }
      )
    end

    it 'returns a status code of 204' do
      expect(subject.destroy(1).status).to eq(204)
    end
  end

  context 'create' do
    let(:company_response) { company_attributes(id: 1) }

    before do
      Excon.stub(
        {
          method: :post,
          path: '/api/v2/companies',
          headers: headers,
          body: company_attributes.to_json
        },
        {
          body: company_response.to_json,
          status: 201
        }
      )
    end

    it 'returns the new company' do
      response = subject.create(company_attributes)
      expect(response).not_to be_nil
    end

    it 'filters out non-whitelisted properties' do
      subject.create(company_attributes(monkey: 'Yes'))
    end

    it 'filters out nil properties' do
      altered_attributes = company_attributes.dup
      altered_attributes.delete(:description)
      Excon.stub(
        {
          method: :post,
          path: '/api/v2/companies',
          headers: headers,
          body: altered_attributes.to_json
        },
        {
          body: company_response.to_json
        }
      )
      subject.create(company_attributes(description: nil))
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
    let(:company_response) { company_attributes(id: 1) }

    before do
      Excon.stub(
        {
          method: :put,
          path: '/api/v2/companies/1',
          headers: headers,
          body: company_attributes.to_json
        },
        {
          body: company_response.to_json,
          status: 201
        }
      )
    end

    it 'returns the updated company' do
      response = subject.update(1, company_attributes)
      expect(response).not_to be_nil
    end

    it 'filters out non-whitelisted properties' do
      subject.update(1, company_attributes(monkey: 'Yes'))
    end

    it 'filters out nil properties' do
      altered_attributes = company_attributes.dup
      altered_attributes.delete(:description)
      Excon.stub(
        {
          method: :put,
          path: '/api/v2/companies/1',
          headers: headers,
          body: altered_attributes.to_json
        },
        {
          body: company_response.to_json
        }
      )
      subject.update(1, company_attributes(description: nil))
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
