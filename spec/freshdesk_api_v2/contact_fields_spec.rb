RSpec.describe FreshdeskApiV2::ContactFields do
  subject do
    client = FreshdeskApiV2::Client.new
    client.contact_fields
  end

  context 'list' do
    before do
      Excon.stub(
        {
          method: :get,
          path: '/api/v2/contact_fields'
        }, {
          body: [{ id: 1, name: 'Field' }].to_json
        })
    end

    it 'return a list of hashes corresponding to the fields on a contact' do
      expect(subject.list).to be_an_instance_of(Array)
    end
  end

end
