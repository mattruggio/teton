# frozen_string_literal: true

require './lib/teton/version'

Gem::Specification.new do |s|
  s.name        = 'teton'
  s.version     = Teton::VERSION
  s.summary     = 'Hierarchical key-value object store interface.'

  s.description = 'Store key-value pair objects in a discoverable hierarchy.  Provides a pluggable interface for multiple back-ends.'

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mattruggio@icloud.com']
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir      = 'exe'
  s.executables = %w[]
  s.homepage    = 'https://github.com/mattruggio/teton'
  s.license     = 'MIT'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/mattruggio/teton/issues',
    'changelog_uri' => 'https://github.com/mattruggio/teton/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/gems/teton',
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage,
    'rubygems_mfa_required' => 'true'
  }

  s.required_ruby_version = '>= 2.7.6'

  s.add_development_dependency('bundler-audit')
  s.add_development_dependency('guard-rspec')
  s.add_development_dependency('pry')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('rubocop-rake')
  s.add_development_dependency('rubocop-rspec')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('simplecov-console')
end
