# frozen_string_literal: true

module Teton
  # Describe what data should be returned when requested.
  class Entry
    attr_reader :path, :data, :created_at, :updated_at

    def initialize(path, data: {}, created_at: Time.now.utc, updated_at: Time.now.utc)
      @path       = path.to_s
      @data       = (data || {}).transform_keys(&:to_s)
      @created_at = created_at || Time.now.utc
      @updated_at = updated_at || Time.now.utc

      freeze
    end

    def [](key)
      data[key]
    end

    def to_s
      "[#{path} |> #{created_at} | #{updated_at}] #{data.map { |k, v| "#{k}: #{v}" }.join(', ')}"
    end
  end
end
