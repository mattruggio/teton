# frozen_string_literal: true

require 'spec_helper'

describe Teton::Entry do
  subject(:example) do
    described_class.new(
      key,
      data: { data_key => data_value },
      created_at: created_at,
      updated_at: updated_at
    )
  end

  let(:key)        { 'users/1' }
  let(:data_key)   { 'first' }
  let(:data_value) { 'bozo' }
  let(:created_at) { Time.parse('2020-05-05').utc }
  let(:updated_at) { Time.parse('2000-01-02').utc }

  describe '#to_s' do
    it 'includes data keys' do
      expect(example.to_s).to include(data_key)
    end

    it 'includes data values' do
      expect(example.to_s).to include(data_value)
    end

    it 'includes key' do
      expect(example.to_s).to include(key)
    end

    it 'includes created_at' do
      expect(example.to_s).to include(created_at.to_s)
    end

    it 'includes updated_at' do
      expect(example.to_s).to include(updated_at.to_s)
    end
  end
end
