# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

# Default test task - runs only unit tests
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = false
end

# Integration test task - runs only integration tests
Rake::TestTask.new(:integration) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/integration/*_test.rb']
  t.verbose = false
end

# Run all tests including integration
desc 'Run all tests including integration tests'
task test_all: %i[test integration]

task default: :test
