# Catacomb

Features:
- the crypt can encrypt only matching keys
- the crypt can encrypt keys regardless of nesting level, if a key is nested in an array in another hash
  the library should still recurse all the way down
- the crypt can be wrapped with a serializer so it can be used in rails for example to store in the
  database
- the crypt process is logically separate and usable from the serializing, who knows if and how
  people want to serialize
- each blob is encrypted with a different iv
- metadata is stored at top level, e.g. algorithm, and key version
- the encrypted values are optionally marshalled so that rich objects can be stored
  - marshal: false -> can be used with other languages
  - marshal: true -> probably not usable in other languages, but more flexible for ruby
- save whether or not anything is encrypted into metadata so things like key rotation can skip rows
- stop marshaling a hash of cipher & iv, just separate with like ':' or something

TODO: Features
- allow user to define key lookup
- allow user to store extra data in metadata, like key version for example
- allow all options to be passed through serializer, or better yet, inject the crypt into serializer
  and create a builder to generate the the serializer with a crypt

## Usage

There is a Crypt class and a Serializer class. The crypt handles all encryption and decryption, and
the serializers for example handles writing to and reading from a database.

### Rails

See rails_example/app/models/person.rb for a working example

```ruby
class Person < ApplicationRecord
  serialize :info, Catacomb::Serializer.new(
    format: :noop, # because rails can handle a hash for json columns
    encrypt_keys: ['ssn'],
    encryption_key: Base64.decode64('5vq+0+mDL+ks8DISlL+y54suJhQgo42Zsm3Z+WEgNuM=')
  )
end
```

### Standalone crypt

We set `keys: [:ssn]`, and catacomb encrypts the values of those keys:

```ruby
[1] pry(main)> catacomb = Catacomb::Crypt.new(encryption_key: Base64.decode64("5vq+0+mDL+ks8DISlL+y54suJhQgo42Zsm3Z+WEgNuM="), keys: [:ssn])
=> #<Catacomb::Crypt:0x00007ff87199f900 @cipher=#<OpenSSL::Cipher:0x00007ff87199f888>, @encryption_key="\xE6\xFA\xBE\xD3\xE9\x83/\xE9,\xF02\x12\x94\xBF\xB2\xE7\x8B.&\x14 \xA3\x8D\x99\xB2m\xD9\xF9a 6\xE3", @keys=["ssn"], @marshal=true, @waterfall=true>
[2] pry(main)> cipherhash, anything_encrypted = catacomb.encrypt({ taco: 'bell', ssn: '111223333' })
=> [{:taco=>"bell", :ssn=>"v0:Zbna2a/8kNu0ievO:YxY9xRKtTJexPsKWhM/xwEKvNjzL3Vfl5Vs+kqRJr9wQ8Uw="}, true]
[3] pry(main)> catacomb.decrypt(cipherhash)
=> {:taco=>"bell", :ssn=>"111223333"}
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'catacomb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install catacomb

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taylorzr/catacomb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
