RSpec.describe FreshdeskApiV2::SearchArgs do
  it 'constructs a simple query' do
    subject.add('name', 'Bob')
    expect(subject.to_query).to eq('"name:Bob"')
  end

  it 'constructs an AND query with parentheses' do
    subject.left_parenthesis
      .add('name', 'Bob')
      .and
      .add('email', 'jim@example.com')
      .right_parenthesis

    expect(subject.to_query).to eq('"(name:Bob AND email:jim%40example.com)"')
  end

  it 'constructs an OR query with parentheses' do
    subject.left_parenthesis
      .add('name', 'Bob')
      .or
      .add('email', 'jim@example.com')
      .right_parenthesis

    expect(subject.to_query).to eq('"(name:Bob OR email:jim%40example.com)"')
  end

  it 'constructs an OR and AND query with parentheses' do
    subject.left_parenthesis
      .add('name', 'Bob')
      .or
      .add('email', 'jim@example.com')
      .right_parenthesis
      .and
      .add('test', 'true')

    expect(subject.to_query).to eq('"(name:Bob OR email:jim%40example.com) AND test:true"')
  end
end
