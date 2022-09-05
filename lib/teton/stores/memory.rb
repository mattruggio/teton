# frozen_string_literal: true

module Teton
  module Stores
    # Plugs in a light-weight store that can be used for modeling other stores.
    class Memory
      CREATED_AT_KEY = 'created_at'
      IDS_KEY        = 'ids'
      INDICES_KEY    = 'indices'
      META_KEY       = 'meta'
      DATA_KEY       = 'data'
      UPDATED_AT_KEY = 'updated_at'

      attr_reader :store

      def initialize(store = {})
        @store = store || {}
      end

      def load!(path)
        from_json!(File.read(path))
      end

      def save!(path)
        dir = File.dirname(path)

        FileUtils.mkdir_p(dir)

        File.write(path, to_json)

        self
      end

      def from_json!(json)
        @store = JSON.parse(json)

        self
      end

      def to_json(*_args)
        store.to_json
      end

      def set(key, data)
        pointer = store

        key.traverse do |part, index|
          if index < key.parts.length - 1
            pointer = insert_traverse(index, pointer, part)
          else
            # last id
            upsert(pointer, part, data)
          end
        end

        self
      end

      def get(key)
        pointer = store

        key.traverse do |part, index|
          break unless pointer

          pointer =
            if index < key.parts.length - 1
              # not last part
              traverse(index, pointer, part)
            elsif (key.parts.length % 2).positive?
              # last part
              entries(key, pointer, part)
            # index
            else
              # id
              entry(key, pointer, part)
            end
        end

        pointer
      end

      def del(key)
        pointer = store

        key.traverse do |part, index|
          break unless pointer

          if index < key.parts.length - 1
            # not last part
            pointer = traverse(index, pointer, part)
          else
            # last part
            pointer.delete(part)
          end
        end

        self
      end

      private

      def upsert(pointer, part, data)
        pointer[part] = record_prototype unless pointer.key?(part)

        pointer[part][DATA_KEY]                 = data
        pointer[part][META_KEY][UPDATED_AT_KEY] = Time.now.utc

        nil
      end

      def insert_traverse(index, pointer, part)
        if index.even?
          # index
          pointer[part] = { IDS_KEY => {} } unless pointer.key?(part)

          pointer[part][IDS_KEY]
        else
          # id
          pointer[part] = record_prototype unless pointer.key?(part)

          pointer[part][INDICES_KEY]
        end
      end

      def traverse(index, pointer, part)
        if index.even?
          # index
          pointer.dig(part, IDS_KEY)
        else
          # id
          pointer.dig(part, INDICES_KEY)
        end
      end

      def entry(key, pointer, part)
        data = pointer.dig(part, DATA_KEY)
        meta = pointer.dig(part, META_KEY)

        return unless data

        Entry.new(
          key.to_s,
          data: data,
          created_at: meta[CREATED_AT_KEY],
          updated_at: meta[UPDATED_AT_KEY]
        )
      end

      def entries(key, pointer, part)
        pointer = pointer.dig(part, IDS_KEY)

        return [] unless pointer

        pointer.map do |inner_part, value|
          Entry.new(
            key.to_s(inner_part),
            data: value[DATA_KEY],
            created_at: value[META_KEY][CREATED_AT_KEY],
            updated_at: value[META_KEY][UPDATED_AT_KEY]
          )
        end
      end

      def record_prototype
        {
          DATA_KEY => {},
          INDICES_KEY => {},
          META_KEY => {
            CREATED_AT_KEY => Time.now.utc,
            UPDATED_AT_KEY => Time.now.utc
          }
        }
      end
    end
  end
end
