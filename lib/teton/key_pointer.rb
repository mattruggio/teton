# frozen_string_literal: true

module Teton
  # Points to a section within a key's parts.  A section can either be a resource or an entry.
  class KeyPointer
    attr_reader :key, :index

    def initialize(key, index)
      @key   = key
      @index = index.to_i

      freeze
    end

    def value
      key.parts[index]
    end

    def not_last?
      !last?
    end

    def last?
      index == key.parts.length - 1
    end

    def entry?
      index.odd?
    end

    def resource?
      index.even? || index.zero?
    end
  end
end
