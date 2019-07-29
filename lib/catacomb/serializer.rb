require 'json'
require 'yaml'

module Catacomb
  class Serializer
    attr_reader :format, :encrypt_keys, :encryption_key

    # TODO: Lookup encryption key by version
    def initialize(format:, encrypt_keys:, encryption_key:)
      @format = format
      @encrypt_keys = encrypt_keys
      @encryption_key = encryption_key
    end

    def load(json)
      payload = loader.call(json)

      if payload #.present? TODO: Use present?
        keys = payload.fetch('metadata').fetch('keys')
        algorithm = OpenSSL::Cipher.new(payload.fetch('metadata').fetch('algorithm'))

        Crypt.new(keys: keys, encryption_key: encryption_key).decrypt(payload.fetch('data'))
      else
        payload
      end
    end

    def dump(data)
      cipherhash, anything_encrypted = Crypt.new(keys: encrypt_keys, encryption_key: encryption_key).encrypt(data)

      payload = {
        'metadata' => { 'keys' => encrypt_keys, 'algorithm' => 'aes-256-gcm', 'key_version' => 0, 'anything_encrypted' => anything_encrypted },
        'data' => cipherhash
      }

      dumper.call(payload)
    end

    def loader
      case format
      when :json
        JSON.method(:parse)
      when :yaml
        YAML.method(:load)
      when :noop
        method(:noop)
      end
    end

    def dumper
      case format
      when :json
        JSON.method(:dump)
      when :yaml
        YAML.method(:dump)
      when :noop
        method(:noop)
      end
    end

    def noop(thing)
      thing
    end
  end
end
