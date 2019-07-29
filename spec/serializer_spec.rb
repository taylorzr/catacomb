RSpec.describe Catacomb::Serializer do
  context 'json' do
    it 'simple' do
      subject = described_class.new(format: :json, encrypt_keys: ['ssn'], encryption_key: Base64.decode64("5vq+0+mDL+ks8DISlL+y54suJhQgo42Zsm3Z+WEgNuM="))

      data = { 'first_name' => 'Zach', 'ssn' => '111223333' }

      result = subject.dump(data)

      undone = subject.load(result)

      expect(undone).to eql(data)
    end

    # TODO: Hmn this could be confusing, maybe just document it?!?` Read about serialization
    # The encrypted date is still a date because we marshal it
    # but the non-encrypted date becomes a string
    pending 'with a date' do
      subject = described_class.new(format: :json, encrypt_keys: ['birth_date'], encryption_key: Base64.decode64("5vq+0+mDL+ks8DISlL+y54suJhQgo42Zsm3Z+WEgNuM="))

      data = { 'birth_date' => Date.new(2014, 11, 15), 'other_date' => Date.new(1982, 6, 16) }

      result = subject.dump(data)

      undone = subject.load(result)

      expect(undone).to eql(data)
    end
  end

  context 'yaml' do
    it 'simple' do
      subject = described_class.new(format: :yaml, encrypt_keys: ['ssn'], encryption_key: Base64.decode64("5vq+0+mDL+ks8DISlL+y54suJhQgo42Zsm3Z+WEgNuM="))

      data = { 'first_name' => 'Zach', 'ssn' => '111223333' }

      result = subject.dump(data)

      undone = subject.load(result)

      expect(undone).to eql(data)
    end

    it 'with a date' do
      subject = described_class.new(format: :yaml, encrypt_keys: ['birth_date'], encryption_key: Base64.decode64("5vq+0+mDL+ks8DISlL+y54suJhQgo42Zsm3Z+WEgNuM="))

      data = { 'birth_date' => Date.new(2014, 11, 15), 'other_date' => Date.new(1982, 6, 16) }

      result = subject.dump(data)

      undone = subject.load(result)

      expect(undone).to eql(data)
    end
  end
end
