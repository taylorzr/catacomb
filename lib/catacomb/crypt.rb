require 'active_support/core_ext/object/deep_dup'
require 'base64'
require 'date'
require 'encryptor' # TODO: Use this or just use raw lib?
require 'openssl'

module Catacomb
  class Crypt
    attr_reader :keys, :encryption_key, :cipher, :waterfall, :marshal

    # TODO: Test marshal option
    # Remove additional marshalling of iv/cipher to be compatible with other languages
    def initialize(keys:, encryption_key:, cipher: OpenSSL::Cipher.new("aes-256-gcm"), waterfall: true, marshal: true)
      @keys = Array(keys).map(&:to_s)
      @encryption_key = encryption_key
      @cipher = cipher
      @waterfall = waterfall
      @marshal = marshal
    end

    def encrypt(data)
      @anything_encrypted = false

      payload = recurse_hash(
        cryptor: method(:encrypt_value),
        data: data.deep_dup,
        crypt: false
      )

      [payload, @anything_encrypted]
    end

    def decrypt(data)
      recurse_hash(
        cryptor: method(:decrypt_value),
        data:    data.deep_dup,
        crypt:   false
      )
    end

    private

    def recurse_hash(cryptor:, data:, crypt:)
      data.each do |key, value|
        encrypted =
          case value
          when Hash
            recurse_hash(cryptor: cryptor, data: value, crypt: keys.include?(key))
          when Array
            recurse_array(cryptor: cryptor, array: value, crypt: keys.include?(key))
          else
            # TODO: Maybe make this configurable?
            # Or it could be configurable per key, e.g.
            # keys: :ssn, pii: { crypt_nest: true }
            if (waterfall && crypt) || keys.include?(key.to_s)
              @anything_encrypted = true
              cryptor.call(value)
            else
              value
            end
          end

        data[key] = encrypted
      end

      data
    end

    def recurse_array(cryptor:, array:, crypt:)
      array.map do |value|
        case value
        when Hash
          recurse_hash(cryptor: cryptor, data: value, crypt: crypt)
        when Array
          # TODO: If waterfall is false, should this set crypt to false? Probably?
          recurse_array(cryptor: cryptor, array: value, crypt: crypt)
        else
          if crypt
            @anything_encrypted = true
            cryptor.call(value)
          else
            value
          end
        end
      end
    end

    # TODO: Maybe move these methods to class level so they can be used elsewhere if desired
    #
    # TODO: Make these configurable. Marshalling is good for ruby because we can store more
    # types/objects but bad for interop between languages because languages couldn't do much with
    # ruby marshalled objects
    def encrypt_value(value)
      iv = cipher.random_iv
      value = if marshal
                Marshal.dump(value)
              else
                value
              end
      ciphertext = Encryptor.encrypt(value: value, iv: iv, key: encryption_key)
      "v0:#{Base64.strict_encode64(iv)}:#{Base64.strict_encode64(ciphertext)}"
    end

    def decrypt_value(value)
      _version, encoded_iv, encoded_ciphertext = value.split(":")
      value = Encryptor.decrypt(
        value: Base64.decode64(encoded_ciphertext),
        iv:    Base64.decode64(encoded_iv),
        key:   encryption_key
      )
      if marshal
        Marshal.load(value)
      else
        value
      end
    end
  end
end
