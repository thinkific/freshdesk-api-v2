RSpec.describe FreshdeskApiV2::Entity do
  class TestEntity < FreshdeskApiV2::Entity
    def endpoint
      'test'
    end
  end

  let(:domain) { 'test-domain' }
  let(:api_key) { 'key' }
  let(:mock_rest_client) { double('Mock REST Client') }

  before do
    FreshdeskApiV2.configure do |conf|
      conf.domain = domain
      conf.api_key = api_key
    end
    @http = FreshdeskApiV2::Http.new(FreshdeskApiV2.configuration)
    allow(@http).to receive(:construct_rest_client).and_return(mock_rest_client)
  end

  after do
    FreshdeskApiV2.reset_configuration!
  end

  subject { TestEntity.new(@http) }

  context 'create' do
    let(:create_attributes) { { name: 'bob' } }
    let(:response_attributes) { create_attributes.merge(id: 1) }
    let(:mock_create_response) { double('Mock Create Response', body: response_attributes.to_json) }

    before do
      allow(mock_rest_client).to receive(:post).and_return(mock_create_response)
    end

    it 'raises an exception when supplied with nil attributes' do
      expect do
        subject.create(nil)
      end.to raise_error(FreshdeskApiV2::CreationException)
    end

    it 'raises an exception when supplied with empty attributes' do
      expect do
        subject.create({})
      end.to raise_error(FreshdeskApiV2::CreationException)
    end

    it 'returns the newly created item' do
      item = subject.create(create_attributes)
      expect(item).not_to be_nil
      expect(item['id']).to eq(1)
      expect(item['name']).to eq('bob')
    end
  end

  context 'update' do
    let(:attributes) { { id: 1, name: 'bob' } }
    let(:mock_update_response) { double('Mock Update Response', body: attributes.to_json) }

    before do
      allow(mock_rest_client).to receive(:put).and_return(mock_update_response)
    end

    it 'raises an exception when supplied with nil attributes' do
      expect do
        subject.update(1, nil)
      end.to raise_error(FreshdeskApiV2::UpdateException)
    end

    it 'raises an exception when supplied with empty attributes' do
      expect do
        subject.update(1, {})
      end.to raise_error(FreshdeskApiV2::UpdateException)
    end

    it 'returns the updated item' do
      item = subject.update(1, attributes)
      expect(item).not_to be_nil
      expect(item['id']).to eq(1)
      expect(item['name']).to eq('bob')
    end
  end

  context 'destroy' do
    let(:mock_delete_response) { double('Mock Delete Response', code: 204) }

    before do
      allow(mock_rest_client).to receive(:delete).and_return(mock_delete_response)
    end

    it 'returns an http status code of 204' do
      expect(subject.destroy(1)).to eq(204)
    end
  end

  context 'show' do
    let(:mock_get_response) { double('Mock Get Response', body: { id: 1, name: 'bob' }.to_json) }

    before do
      allow(mock_rest_client).to receive(:get).and_return(mock_get_response)
    end

    it 'returns the item requested' do
      item = subject.show(1)
      expect(item).not_to be_nil
      expect(item['id']).to eq(1)
      expect(item['name']).to eq('bob')
    end
  end

  context 'search' do
    let(:query) { '(active:true)' }
    let(:mock_get_response) do
      double('Mock Get Response',
        body: { 'total' => 1, 'results' => [{ id: '1', name: 'Bob' }] }.to_json
      )
    end

    before do
      allow(mock_rest_client).to receive(:get).and_return(mock_get_response)
    end

    it 'raises an exception when not called with a query' do
      expect do
        subject.search(
          '',
          first_page: 1
        )
      end.to raise_error(FreshdeskApiV2::SearchException)
    end

    it 'raises an exception when called with a start_page of less than 0' do
      expect do
        subject.search(
          query,
          first_page: -1
        )
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end

    it 'raises an exception when called with an last_page of less than start_page' do
      expect do
        subject.search(
          query,
          first_page: 2,
          last_page: 1
        )
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end

    it 'does not raise an exception when called with an last_page equal to start_page' do
      expect do
        subject.search(
          query,
          first_page: 2,
          last_page: 2
        )
      end.not_to raise_error
    end

    it 'uses last_page as integer max if not specified' do
      url = 'https://test-domain.freshdesk.com/api/v2/search/test?page=1&query="(active:true)"'
      expect(@http).to receive(:search_paginate).with(url, FreshdeskApiV2::Utils::INTEGER_MAX)
      subject.search(
        query,
        first_page: 1
      )
    end

    it 'uses last_page as specified' do
      url = 'https://test-domain.freshdesk.com/api/v2/search/test?page=1&query="(active:true)"'
      expect(@http).to receive(:search_paginate).with(url, 2)
      subject.search(
        query,
        first_page: 1,
        last_page: 2
      )
    end
  end

  context 'list' do
    let(:mock_get_response) { double('Mock Get Response', body: [{ id: 1, name: 'bob' }].to_json) }
    let(:mock_links) { double('Mock Links', by_rel: nil) }

    before do
      allow(mock_rest_client).to receive(:get).and_return(mock_get_response)
      allow_any_instance_of(Nitlink::Parser).to receive(:parse).and_return(mock_links)
    end

    it 'raises an exception when called with a start_page of less than 0' do
      expect do
        subject.list(
          first_page: -1,
          per_page: 100
        )
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end

    it 'raises an exception when called with an last_page of less than start_page' do
      expect do
        subject.list(
          first_page: 2,
          last_page: 1,
          per_page: FreshdeskApiV2::Utils::MAX_PAGE_SIZE
        )
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end

    it 'does not raise an exception when called with an last_page equal to start_page' do
      expect do
        subject.list(
          first_page: 2,
          last_page: 2,
          per_page: FreshdeskApiV2::Utils::MAX_PAGE_SIZE
        )
      end.not_to raise_error
    end

    it "raises an exception when called with a per_page of greater than #{FreshdeskApiV2::Utils::MAX_PAGE_SIZE}" do
      expect do
        subject.list(
          first_page: 1,
          per_page: FreshdeskApiV2::Utils::MAX_PAGE_SIZE + 1
        )
      end.to raise_error(FreshdeskApiV2::PaginationException)
    end

    it 'uses last_page as integer max if not specified' do
      url = 'https://test-domain.freshdesk.com/api/v2/test?page=1&per_page=100'
      expect(@http).to receive(:paginate).with(url, FreshdeskApiV2::Utils::INTEGER_MAX)
      subject.list(
        first_page: 1,
        per_page: FreshdeskApiV2::Utils::MAX_PAGE_SIZE
      )
    end

    it 'uses last_page as specified' do
      url = 'https://test-domain.freshdesk.com/api/v2/test?page=1&per_page=100'
      expect(@http).to receive(:paginate).with(url, 2)
      subject.list(
        first_page: 1,
        last_page: 2,
        per_page: FreshdeskApiV2::Utils::MAX_PAGE_SIZE
      )
    end

    it 'constructs a url with per_page as specified' do
      url = 'https://test-domain.freshdesk.com/api/v2/test?page=1&per_page=15'
      expect(@http).to receive(:paginate).with(url, FreshdeskApiV2::Utils::INTEGER_MAX)
      subject.list(
        first_page: 1,
        per_page: 15
      )
    end
  end
end
