require 'byebug'
RSpec.describe FreshdeskApiV2::Companies do
  before do
    @mock_http = double('Mock HTTP', domain: 'test')
  end

  subject { FreshdeskApiV2::Companies.new(@mock_http) }

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
    let(:companies) { [company_attributes(id: 1, name: 'Company 1'), company_attributes(id: 1, name: 'Company 2')] }

    before do
      allow(@mock_http).to receive(:paginated_get).and_return(companies)
    end

    it 'returns a list of companies' do
      expect(subject.list).to be_instance_of(Array)
    end

    it 'raises an exception when last_page is less than first_page' do
      expect do
        subject.list(first_page: 2, last_page: 1)
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end

    it "raises an exception when per_page is greater than #{FreshdeskApiV2::Utils::MAX_PAGE_SIZE}" do
      expect do
        subject.list(first_page: 1, per_page: 101)
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end
  end

  context 'search' do
    let(:query) do
      q = FreshdeskApiV2::SearchArgs.new
      q.add('name', 'Bob')
      q
    end

    let(:companies) { [company_attributes(id: 1, name: 'Company 1'), company_attributes(id: 1, name: 'Company 2')] }

    before do
      allow(@mock_http).to receive(:paginated_search).and_return(companies)
    end

    it 'returns a list of companies matching the query' do
      expect(subject.search(query)).to be_instance_of(Array)
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

    it 'raises an exception when last_page is less than first_page' do
      expect do
        subject.search(query, first_page: 2, last_page: 1)
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end

    it "raises an exception when last_page is greater than #{FreshdeskApiV2::Utils::MAX_SEARCH_PAGES}" do
      expect do
        subject.search(query, first_page: 1, last_page: 11)
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end
  end

  context 'show' do
    let(:response) { double('Mock HTTP Response', body: company_attributes.to_json) }

    before do
      allow(@mock_http).to receive(:get).and_return(response)
    end

    it 'returns the company' do
      expect(subject.show(1)).not_to be_nil
    end
  end

  context 'destroy' do
    let(:response) { double('Mock HTTP Response', status: 204) }

    before do
      allow(@mock_http).to receive(:delete).and_return(response)
    end

    it 'deletes the company' do
      expect(@mock_http).to receive(:delete).and_return(response)
      subject.destroy(1)
    end

    it 'returns a status code of 204' do
      expect(subject.destroy(1)).to eq(204)
    end
  end

  context 'create' do
    let(:endpoint) { 'https://test.freshdesk.com/api/v2/companies' }
    let(:response) { double('Mock HTTP Response', body: company_attributes.to_json) }

    before do
      allow(@mock_http).to receive(:post).and_return(response)
    end

    it 'creates the company' do
      expect(@mock_http).to receive(:post).with(endpoint, company_attributes).and_return(response)
      subject.create(company_attributes)
    end

    it 'returns the company' do
      response = subject.create(company_attributes)
      expect(response).not_to be_nil
    end

    it 'filters out non-whitelisted properties' do
      expect(@mock_http).to receive(:post).with(endpoint, company_attributes)
      subject.create(company_attributes(monkey: 'Yes'))
    end

    it 'filters out nil properties' do
      altered_attributes = company_attributes.dup
      altered_attributes.delete(:description)
      expect(@mock_http).to receive(:post).with(endpoint, altered_attributes)
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
    let(:endpoint) { 'https://test.freshdesk.com/api/v2/companies/1' }
    let(:response) { double('Mock HTTP Response', body: company_attributes(id: 1).to_json) }

    before do
      allow(@mock_http).to receive(:put).and_return(response)
    end

    it 'updates the company' do
      expect(@mock_http).to receive(:put).with(endpoint, company_attributes).and_return(response)
      subject.update(1, company_attributes)
    end

    it 'returns the company' do
      response = subject.update(1, company_attributes)
      expect(response).not_to be_nil
    end

    it 'filters out non-whitelisted properties' do
      expect(@mock_http).to receive(:put).with(endpoint, company_attributes)
      subject.update(1, company_attributes(monkey: 'Yes'))
    end

    it 'filters out nil properties' do
      altered_attributes = company_attributes.dup
      altered_attributes.delete(:description)
      expect(@mock_http).to receive(:put).with(endpoint, altered_attributes)
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
