# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleExpectations
# rubocop:disable RSpec/ExampleLength
describe Teton do
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
end
# rubocop:enable RSpec/ExampleLength
# rubocop:enable RSpec/MultipleExpectations
