# frozen_string_literal: true

require_relative 'in_memory_store'
require_relative 'location'

module Teton
  # The main interface for any store backend.
  class Db
    DEFAULT_SEPARATOR = '/'

    attr_reader :separator, :store

    def initialize(separator: DEFAULT_SEPARATOR, store: InMemoryStore.new)
      raise ArgumentError, 'separator is required' if separator.to_s.empty?

      @separator = separator.to_s
      @store     = store

      freeze
    end

    def set(path, data)
      location = location(path)

      raise ArgumentError, "path: #{path} does not point to an entry" unless location.entry?

      store.set(location, string_keys_and_values(data))

      self
    end

    def get(path)
      store.get(location(path))
    end

    def del(path)
      tap { store.del(location(path)) }
    end

    private

    def location(path)
      Location.new(path, separator: separator)
    end

    def string_keys_and_values(hash)
      (hash || {}).to_h { |k, v| [k.to_s, v.to_s] }
    end
  end
end
