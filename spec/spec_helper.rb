# typed: false
# frozen_string_literal: true

require "bundler/setup"
require "mcp/datetime"
require "json"
require "stringio"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option
  Kernel.srand(config.seed)
end

# Helper method to simulate MCP communication
def send_request(server, request)
  input = StringIO.new(request.to_json + "\n")
  output = StringIO.new

  # Temporarily redirect stdin/stdout
  old_stdin = $stdin
  old_stdout = $stdout

  $stdin = input
  $stdout = output

  # Run one iteration of the server loop
  server.send(:handle_request, JSON.parse(request.to_json))
rescue StandardError => e
  { error: e.message }
ensure
  $stdin = old_stdin
  $stdout = old_stdout
end
