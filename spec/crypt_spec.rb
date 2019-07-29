RSpec.describe Catacomb::Crypt do
  let(:encryption_key) { Base64.decode64("5vq+0+mDL+ks8DISlL+y54suJhQgo42Zsm3Z+WEgNuM=") }

  it 'basic strings' do
    subject = described_class.new(encryption_key: encryption_key, keys: :ssn)

    data = {
      taco: 'bell',
      ssn: '111223333'
    }

    encrypted, anything = subject.encrypt(data)

    undone = subject.decrypt(encrypted)

    expect(undone).to eql(data)
  end

  it 'marshals objects' do
    subject = described_class.new(encryption_key: encryption_key, keys: :birth_date)

    data = {
      taco: 'bell',
      birth_date: Date.new(2014, 11, 15)
    }

    result, _ = subject.encrypt(data)
    undone = subject.decrypt(result)

    expect(undone).to eql(data)
  end

  it 'handles array values' do
    subject = described_class.new(encryption_key: encryption_key, keys: :pii)

    data = { pii: [ 'Zach', '111223333' ] }

    result, _ = subject.encrypt(data)
    undone = subject.decrypt(result)

    expect(undone).to eql(data)
  end

  it 'handles arrays of arrays' do
    subject = described_class.new(encryption_key: encryption_key, keys: :pii)

    data = { pii: [ { first_name: 'Zach' }, ['111223333'] ] }

    result, _ = subject.encrypt(data)
    undone = subject.decrypt(result)

    expect(undone).to eql(data)
  end

  it 'doesnt marhsal entire hashes, same for arrays!!!' do
    subject = described_class.new(encryption_key: encryption_key, keys: [:person, :ssn])

    data = {
      taco: 'bell',
      person: { ssn: '111223333' }
    }

    encrypted, _ = subject.encrypt(data)

    undone = subject.decrypt(encrypted)

    expect(undone).to eql(data)
    expect(encrypted.fetch(:person)).to have_key(:ssn)
  end

  it 'recurses' do
    subject = described_class.new(encryption_key: encryption_key, keys: [:person, :ssn])

    data = {
      taco: 'bell',
      person: { ssn: '111223333', pii: { first_name: 'Zach', last_name: 'Taylor' }}
    }

    encrypted, _ = subject.encrypt(data)

    expect(encrypted.dig(:person, :ssn)).not_to eql('111223333')

    undone = subject.decrypt(encrypted)

    expect(encrypted.dig(:person, :ssn)).not_to eql('111223333')
    expect(undone).to eql(data)
  end
end
