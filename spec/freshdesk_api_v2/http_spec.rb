RSpec.describe FreshdeskApiV2::Http do
  subject do
    config = FreshdeskApiV2::Config.new(api_key: 'key', domain: 'test')
    FreshdeskApiV2::Http.new(config)
  end

  let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }

  describe '#get' do
    before do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/test',
          headers: headers
        },
        {
          body: { id: 1, name: 'test' }.to_json,
          status: 200
        }
      )
    end

    it 'performs a GET for the resource' do
      response = subject.get('test', headers)
      json = JSON.parse(response.body)
      expect(json).not_to be_nil
      expect(json['id']).to eq(1)
      expect(json['name']).to eq('test')
    end
  end

  describe '#put' do
    let(:attributes) { { id: 1, name: 'test' } }

    before do
      Excon.stub(
        {
          method: :put,
          path: '/api/v2/test/1',
          body: attributes.to_json,
          headers: headers
        },
        {
          body: { id: 1, name: 'test' }.to_json,
          status: 200
        }
      )
    end

    it 'performs a PUT with the appropriate data' do
      subject.put('test/1', attributes, headers)
    end
  end

  describe '#post' do
    let(:attributes) { { id: 1, name: 'test' } }

    before do
      Excon.stub(
        {
          method: :post,
          path: '/api/v2/test',
          body: attributes.to_json,
          headers: headers
        },
        {
          body: { id: 1, name: 'test' }.to_json,
          status: 201
        }
      )
    end

    it 'performs a POST with the appropriate data' do
      subject.post('test', attributes, headers)
    end
  end

  describe '#delete' do
    before do
      Excon.stub(
        {
          method: :delete,
          path: '/api/v2/test/1',
          headers: headers
        },
        {
          body: { id: 1, name: 'test' }.to_json,
          status: 204
        }
      )
    end

    it 'performs a DELETE with the appropriate data' do
      subject.delete('test/1', headers)
    end
  end
end
