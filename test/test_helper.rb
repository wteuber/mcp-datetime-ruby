# typed: false
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'mcp/datetime'
require 'minitest/autorun'
require 'json'
require 'stringio'

class MCPTestHelper < Minitest::Test
  def setup
    # Suppress stderr for all tests
    @original_stderr = $stderr
    $stderr = StringIO.new
  end

  def teardown
    # Restore stderr after each test
    $stderr = @original_stderr
  end

  private

  def create_server
    MCP::DateTime::Server.new
  end

  def send_request(server, request)
    # Use the server's private method directly for testing
    server.send(:handle_request, request)
  end

  def parse_json_response(response)
    return if response.nil?

    response
  end
end
