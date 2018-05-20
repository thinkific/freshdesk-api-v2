RSpec.describe FreshdeskApiV2 do
  it 'has a version number' do
    expect(FreshdeskApiV2::VERSION).not_to be nil
  end

  it 'can be configured' do
    expect(FreshdeskApiV2).to respond_to(:configure)
  end

  it 'tests things' do

  end
end
