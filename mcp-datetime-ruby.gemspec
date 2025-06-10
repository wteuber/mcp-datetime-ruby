# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'mcp-datetime-ruby'
  spec.version = '0.1.0'
  spec.authors = ['Wolfgang Teuber']
  spec.email = ['knugie@gmx.net']

  spec.summary = 'MCP (Model Context Protocol) DateTime Server for Ruby'
  spec.description = 'A Ruby implementation of an MCP server that provides datetime tools for AI assistants'
  spec.homepage = 'https://github.com/wteuber/mcp-datetime-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob('{bin,lib}/**/*') + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.bindir = 'bin'
  # Executable is created by the rubygems plugin in ~/bin
  # spec.executables = ["mcp-datetime-ruby"]
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'json', '~> 2.0'

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
