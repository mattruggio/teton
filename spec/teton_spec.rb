# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleExpectations
# rubocop:disable RSpec/ExampleLength
describe Teton do
  # The other classes in this library need to be better unit-tested, but this at least gives
  # the library a regression of the most common scenarios.
  it 'passes full API integration test' do    
    # Stage data
    db = Teton::Db.new

    # Test SET

    bozo_key = 'users/1'
    db.set(bozo_key, first: 'bozo', last: 'clown')

    inception_key = "#{bozo_key}/movies/1"
    db.set(inception_key, title: 'Inception', year: 2010)

    inception_actors_key = "#{inception_key}/actors"

    leo_key = "#{inception_actors_key}/1"
    db.set(leo_key, first: 'Leonardo', last: 'DiCaprio', star: true)

    tom_key = "#{inception_actors_key}/2"
    db.set(tom_key, first: 'Tom', last: 'Hardy', star: true)

    # Persist to disk

    db_key = File.join(TEMP_DIR, "#{SecureRandom.uuid}.json")

    db.store.save!(db_key)

    # Load staged data from disk

    db = Teton::Db.new

    db.store.load!(db_key)

    # Test GET

    bozo = db.get(bozo_key)

    expect(bozo['first']).to eq('bozo')
    expect(bozo['last']).to eq('clown')
    expect(bozo.key).to eq(bozo_key)

    inception = db.get(inception_key)

    expect(inception['title']).to eq('Inception')
    expect(inception['year']).to eq('2010')
    expect(inception.key).to eq(inception_key)

    leo = db.get(leo_key)

    expect(leo['first']).to eq('Leonardo')
    expect(leo['last']).to eq('DiCaprio')
    expect(leo['star']).to eq('true')
    expect(leo.key).to eq(leo_key)

    tom = db.get(tom_key)

    expect(tom['first']).to eq('Tom')
    expect(tom['last']).to eq('Hardy')
    expect(tom['star']).to eq('true')
    expect(tom.key).to eq(tom_key)

    inception_actors = db.get(inception_actors_key)

    expect(inception_actors.length).to eq(2)

    leo = inception_actors[0]

    expect(leo['first']).to eq('Leonardo')
    expect(leo['last']).to eq('DiCaprio')
    expect(leo['star']).to eq('true')
    expect(leo.key).to eq(leo_key)

    tom = inception_actors[1]

    expect(tom['first']).to eq('Tom')
    expect(tom['last']).to eq('Hardy')
    expect(tom['star']).to eq('true')
    expect(tom.key).to eq(tom_key)

    # Test COUNT

    expect(db.count('doesnt_exist')).to eq(0)
    expect(db.count('doesnt_exist/1')).to eq(0)
    expect(db.count(bozo_key)).to eq(1)
    expect(db.count(inception_key)).to eq(1)
    expect(db.count(inception_actors_key)).to eq(2)

    # Test DEL

    db.del(tom_key)

    tom = db.get(tom_key)

    expect(tom).to be_nil

    db.del(inception_actors_key)

    inception_actors = db.get(inception_actors_key)

    expect(inception_actors).to be_empty

    db.del(bozo_key)

    inception = db.get(inception_key)

    expect(inception).to be_nil

    bozo = db.get(bozo_key)

    expect(bozo).to be_nil
  end

  describe 'Paging' do
    subject(:db) { Teton::Db.new }

    let(:practice_key) { 'practices/1' }
    let(:patients_key) { "#{practice_key}/patients" }

    before do
      db.set(practice_key, name: 'The Happy Practice')

      (1..20).each do |i|
        patient_key = "#{patients_key}/#{i}"

        db.set(patient_key, first: 'Dobby', middle: 'is', last: "Number#{i}")
      end
    end

    it 'limits with no skip' do
      patients = db.get(patients_key, limit: 3)

      expected_lasts = %w[Number1 Number2 Number3]
      actual_lasts = patients.map { |p| p[:last] }

      expect(actual_lasts).to eq(expected_lasts)
    end

    it 'limits with skip' do
      patients = db.get(patients_key, limit: 3, skip: 3)

      expected_lasts = %w[Number4 Number5 Number6]
      actual_lasts = patients.map { |p| p[:last] }

      expect(actual_lasts).to eq(expected_lasts)
    end

    it 'skips with no limit' do
      patients = db.get(patients_key, skip: 18)

      expected_lasts = %w[Number19 Number20]
      actual_lasts = patients.map { |p| p[:last] }

      expect(actual_lasts).to eq(expected_lasts)
    end

    it 'limit too large just goes to the end' do
      patients = db.get(patients_key, skip: 19, limit: 100)

      expected_lasts = %w[Number20]
      actual_lasts = patients.map { |p| p[:last] }

      expect(actual_lasts).to eq(expected_lasts)
    end

    it 'skip too large returns nothing' do
      patients = db.get(patients_key, skip: 25)

      expect(patients).to be_empty
    end
  end
end
# rubocop:enable RSpec/ExampleLength
# rubocop:enable RSpec/MultipleExpectations
