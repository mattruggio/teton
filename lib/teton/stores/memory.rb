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

      # Main Object API

      def set(key, data)
        store_pointer = insert_traverse_to_last(key)

        upsert(store_pointer, key.last_part, data)

        self
      end

      def get(key)
        store_pointer = traverse_to_last(key)

        return unless store_pointer

        if key.resource?
          entries(key, store_pointer, key.last_part)
        else
          entry(key, store_pointer, key.last_part)
        end
      end

      def del(key)
        store_pointer = traverse_to_last(key)

        return self unless store_pointer

        store_pointer.delete(key.last_part)

        self
      end

      def count(key)
        store_pointer = traverse_to_last(key)

        return 0 unless store_pointer

        if key.resource?
          (store_pointer.dig(key.last_part, IDS_KEY) || {}).keys.length
        else
          store_pointer.dig(key.last_part, DATA_KEY) ? 1 : 0
        end
      end

      # Persistence API

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

      def insert_traverse_to_last(key)
        store_pointer = store

        key.traverse do |key_pointer|
          store_pointer = insert_traverse(key_pointer.index, store_pointer, key_pointer.value) if key_pointer.not_last?
        end

        store_pointer
      end

      def traverse_to_last(key)
        store_pointer = store

        key.traverse do |key_pointer|
          break unless store_pointer

          store_pointer = traverse(key_pointer.index, store_pointer, key_pointer.value) if key_pointer.not_last?
        end

        store_pointer
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
