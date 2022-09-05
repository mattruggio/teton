# frozen_string_literal: true

module Teton
  # Understands a fully-qualified path to a resource or resources.
  class Key
    attr_reader :path, :parts, :separator

    def initialize(path, separator:)
      raise ArgumentError, 'separator is required' if separator.to_s.empty?
      raise ArgumentError, 'path is required'      if path.to_s.empty?

      @path      = path.to_s
      @parts     = path.to_s.split(separator)
      @separator = separator.to_s

      freeze
    end

    def to_s(suffix_keys = [])
      suffix_keys = Array(suffix_keys)

      (parts + suffix_keys).join(separator)
    end

    def traverse(&block)
      parts.each_with_index(&block)
    end

    def entry?
      parts.length.even?
    end

    def resource?
      parts.length.odd?
    end
  end
end
