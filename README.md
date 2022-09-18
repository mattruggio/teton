# Teton

[![Gem Version](https://badge.fury.io/rb/teton.svg)](https://badge.fury.io/rb/teton) [![Ruby Gem CI](https://github.com/mattruggio/teton/actions/workflows/rubygem.yml/badge.svg)](https://github.com/mattruggio/teton/actions/workflows/rubygem.yml) [![Maintainability](https://api.codeclimate.com/v1/badges/787a5d512223e85efd69/maintainability)](https://codeclimate.com/github/mattruggio/teton/maintainability) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

#### Hierarchical key-value object store

---

Store key-value pair-based objects in a key-based hierarchy.  Provides a pluggable interface for multiple back-ends.

## Installation

To install through Rubygems:

````
gem install teton
````

You can also add this to your Gemfile using:

````
bundle add teton
````

## Examples

The main API is made up of these instance methods:

Method                                 | Description
---------------------------------------| --------------------------------------------------------------
`Db#set(key, data = {})`               | Set an entries data to the passed in values.
`Db#get(key, limit: nil, skip: nil)`   | Get the entry if it exists or nil if it does not.  If the key is a resource then it will always return an array.
`Db#del(key)`                          | Delete the key and all children of the key from the store.
`Db#count(key)`                        | The number of entries directly under a key if the key is a resource.  If they key is an entry then 1 if the entry exists and 0 if it does not exist.

Note(s):

* limit and skip are optional and only apply to resource keys, not entry keys.

#### Setting Up Database

````ruby
db = Teton::Db.new
````

#### Setting Objects

````ruby
bozo_key             = 'users/1'
inception_key        = "#{bozo_key}/movies/1"      # => users/1/movies/1
inception_actors_key = "#{inception_key}/actors"   # => users/1/movies/1/actors
leo_key              = "#{inception_actors_key}/1" # => users/1/movies/1/actors/1
tom_key              = "#{inception_actors_key}/2" # => users/1/movies/1/actors/2

db.set(bozo_key, first: 'bozo', last: 'clown')
  .set(inception_key, title: 'Inception', year: 2010)
  .set(leo_key, first: 'Leonardo', last: 'DiCaprio', star: true)
  .set(tom_key, first: 'Tom', last: 'Hardy', star: true)
````

Note(s):

* `#set` returns self.
* If an inner key within the key does not exist then it will be added to the hierarchy.

#### Retrieving Objects

````ruby
bozo             = db.get(bozo_key)             # => Teton::Entry
inception        = db.get(inception_key)        # => Teton::Entry
leo              = db.get(leo_key)              # => Teton::Entry
tom              = db.get(tom_key)              # => Teton::Entry
inception_actors = db.get(inception_actors_key) # => [Teton::Entry]
````

Note(s):

* If a key does not exist then nil will be returned.
* If a key is for a resource then it will return an array.

#### Deleting Objects

````ruby
db.del(leo_key)
  .del(inception_key)
  .del(bozo_key)
````

Note(s):

* `#del` returns self.
* If an inner key is deleted then all child keys in the hierarchy are deleted.

#### Backends

The back-end: `Teton::Stores::Memory` will be used by default.  You can also pass in another back-end if one exists:

````ruby
store = Teton::Stores::MySQL.new(host: '127.0.0.1', db: 'teton_entries')
db    = Teton::Db.new(store: store)
````

Note(s):

* Each back-end may require specific configuration so it is up to you to check the desired back-end's documentation.
* Currently `Teton::Stores::MySQL` does not exist as an implementation but any store (i.e. MySQL, PostgeSQL, Redis, S3, traditional file systems) should all be possible.

Each back-end provides its own persistence mechanics.  For example, `Teton::Stores::Memory` provides persistence/serialization methods:

Method              | Description
------------------- | -----------
`#load!(path(`      | Load from a file on disk
`#save!(path)`      | Save to a file on disk
`#from_json!`       | Deserialize a passed in JSON string
`#to_json`          | Return a serialized JSON string

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check teton.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:mattruggio/teton.git)
4. Navigate to the root folder (cd teton)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````zsh
bin/rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````zsh
bin/guard
````

Also, do not forget to run Rubocop:

````zsh
bin/rubocop
````

And auditing the dependencies:

````zsh
bin/bundler-audit check --update
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into main
2. Update `version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push main to remote and ensure CI builds main successfully
6. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mattruggio/teton/blob/main/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
