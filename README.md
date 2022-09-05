# Teton

[![Gem Version](https://badge.fury.io/rb/teton.svg)](https://badge.fury.io/rb/teton) [![Ruby Gem CI](https://github.com/mattruggio/teton/actions/workflows/rubygem.yml/badge.svg)](https://github.com/mattruggio/teton/actions/workflows/rubygem.yml) [![Maintainability](https://api.codeclimate.com/v1/badges/787a5d512223e85efd69/maintainability)](https://codeclimate.com/github/mattruggio/teton/maintainability) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

#### Hierarchical key-value object store interface

---

Store key-value pair objects in a discoverable hierarchy.  Provides a pluggable interface for multiple back-ends.

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

TODO

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
