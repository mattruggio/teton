# frozen_string_literal: true

require_relative 'entry'
require_relative 'key'
require_relative 'stores/memory'

module Teton
  # The main interface for any store backend.
  class Db
    DEFAULT_SEPARATOR = '/'

    attr_reader :separator, :store

    def initialize(separator: DEFAULT_SEPARATOR, store: Stores::Memory.new)
      raise ArgumentError, 'separator is required' if separator.to_s.empty?

      @separator = separator.to_s
      @store     = store

      freeze
    end

    def set(key, data)
      key = key(key)

      raise ArgumentError, "key: #{key} does not point to an entry" unless key.entry?

      store.set(key, string_keys_and_values(data))

      self
    end

    def get(key, limit: nil, skip: nil)
      store.get(
        key(key),
        limit: zero_floor_or_nil(limit),
        skip: zero_floor_or_nil(skip)
      )
    end

    def del(key)
      tap { store.del(key(key)) }
    end

    def count(key)
      store.count(key(key))
    end

    private

    def zero_floor_or_nil(value)
      return unless value

      value ? [value, 0].max : nil
    end

    def key(key)
      key.is_a?(Key) ? key : Key.new(key, separator: separator)
    end

    def string_keys_and_values(hash)
      (hash || {}).to_h { |k, v| [k.to_s, v.to_s] }
    end
  end
end
