RSpec.describe FreshdeskApiV2::CompanyFields do
  subject do
    client = FreshdeskApiV2::Client.new
    client.company_fields
  end

  context 'list' do
    before do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/company_fields'
        }, {
          body: [{ id: 1, name: 'Field' }].to_json
        })
    end

    it 'return a list of hashes corresponding to the fields on a company' do
      expect(JSON.parse(subject.list.body)).to be_an_instance_of(Array)
    end
  end
end
