class Person < ApplicationRecord
  serialize :info, Catacomb::Serializer.new(
    format: :noop, # because rails can handle a hash for json columns
    encrypt_keys: ['ssn'],
    encryption_key: Base64.decode64('5vq+0+mDL+ks8DISlL+y54suJhQgo42Zsm3Z+WEgNuM=')
  )
end
