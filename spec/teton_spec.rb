# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleExpectations
# rubocop:disable RSpec/ExampleLength
describe Teton do
  it 'passes full API integration test' do
    # Stage data
    db = Teton::Db.new

    # Test SET

    bozo_path = 'users/1'
    db.set(bozo_path, first: 'bozo', last: 'clown')

    inception_path = "#{bozo_path}/movies/1"
    db.set(inception_path, title: 'Inception', year: 2010)

    inception_actors_path = "#{inception_path}/actors"

    leo_path = "#{inception_actors_path}/1"
    db.set(leo_path, first: 'Leonardo', last: 'DiCaprio', star: true)

    tom_path = "#{inception_actors_path}/2"
    db.set(tom_path, first: 'Tom', last: 'Hardy', star: true)

    # Persist to disk

    db_path = File.join(TEMP_DIR, "#{SecureRandom.uuid}.json")

    db.store.save!(db_path)

    # Load staged data from disk

    db = Teton::Db.new

    db.store.load!(db_path)

    # Test GET

    bozo = db.get(bozo_path)

    expect(bozo['first']).to eq('bozo')
    expect(bozo['last']).to eq('clown')
    expect(bozo.path).to eq(bozo_path)

    inception = db.get(inception_path)

    expect(inception['title']).to eq('Inception')
    expect(inception['year']).to eq('2010')
    expect(inception.path).to eq(inception_path)

    leo = db.get(leo_path)

    expect(leo['first']).to eq('Leonardo')
    expect(leo['last']).to eq('DiCaprio')
    expect(leo['star']).to eq('true')
    expect(leo.path).to eq(leo_path)

    tom = db.get(tom_path)

    expect(tom['first']).to eq('Tom')
    expect(tom['last']).to eq('Hardy')
    expect(tom['star']).to eq('true')
    expect(tom.path).to eq(tom_path)

    inception_actors = db.get(inception_actors_path)

    expect(inception_actors.length).to eq(2)

    leo = inception_actors[0]

    expect(leo['first']).to eq('Leonardo')
    expect(leo['last']).to eq('DiCaprio')
    expect(leo['star']).to eq('true')
    expect(leo.path).to eq(leo_path)

    tom = inception_actors[1]

    expect(tom['first']).to eq('Tom')
    expect(tom['last']).to eq('Hardy')
    expect(tom['star']).to eq('true')
    expect(tom.path).to eq(tom_path)

    # Test DEL

    db.del(tom_path)

    tom = db.get(tom_path)

    expect(tom).to be_nil

    db.del(inception_actors_path)

    inception_actors = db.get(inception_actors_path)

    expect(inception_actors).to be_empty

    db.del(bozo_path)

    inception = db.get(inception_path)

    expect(inception).to be_nil

    bozo = db.get(bozo_path)

    expect(bozo).to be_nil
  end
end
# rubocop:enable RSpec/ExampleLength
# rubocop:enable RSpec/MultipleExpectations
