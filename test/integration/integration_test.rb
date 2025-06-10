# typed: false
# frozen_string_literal: true

require 'test_helper'
require 'open3'
require 'timeout'

class IntegrationTest < MCPTestHelper
  def test_full_server_communication
    executable = File.expand_path('../../bin/mcp-datetime-ruby', __dir__)

    Open3.popen3(executable) do |stdin, stdout, _stderr, wait_thr|
      # Send initialize request
      request = {
        jsonrpc: '2.0',
        method: 'initialize',
        params: {
          protocolVersion: '2024-11-05',
          capabilities: {},
          clientInfo: {
            name: 'test-client',
            version: '1.0.0'
          }
        },
        id: 1
      }

      stdin.puts(request.to_json)
      stdin.flush

      # Read response with timeout
      response = Timeout.timeout(2) do
        stdout.gets
      end

      parsed = JSON.parse(response)
      assert_equal('2.0', parsed['jsonrpc'])
      assert_equal(1, parsed['id'])
      assert(parsed['result']['serverInfo'])

      # Send tools/list request
      request = {
        jsonrpc: '2.0',
        method: 'tools/list',
        params: {},
        id: 2
      }

      stdin.puts(request.to_json)
      stdin.flush

      response = Timeout.timeout(2) do
        stdout.gets
      end

      parsed = JSON.parse(response)
      assert_equal(2, parsed['result']['tools'].length)

      # Close stdin to signal EOF
      stdin.close

      # Wait for process to exit
      wait_thr.value
    end
  end

  def test_executable_exists
    executable = File.expand_path('../../bin/mcp-datetime-ruby', __dir__)
    assert(File.exist?(executable), 'Executable should exist')
    assert(File.executable?(executable), 'Executable should be executable')
  end
end
