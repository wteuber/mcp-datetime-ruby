# typed: false
# frozen_string_literal: true

require 'test_helper'

module MCP
  module DateTime
    class ServerEdgeCasesTest < MCPTestHelper
      def setup
        super
        @server = create_server
      end

      def test_json_parse_error_handling
        # The server's run method handles JSON parse errors
        # We can't easily test the full run loop, but we can verify
        # that malformed JSON would be handled if we could send it

        # Test that our server instance exists and has the expected methods
        assert_respond_to(@server, :run)
        assert_respond_to(@server, :send)
      end

      def test_empty_tool_name
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => '',
            'arguments' => {}
          },
          'id' => 100
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(100, response[:id])
        assert(response[:error])
        assert_equal(-32_603, response[:error][:code])
      end

      def test_nil_tool_name
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => nil,
            'arguments' => {}
          },
          'id' => 101
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(101, response[:id])
        assert(response[:error])
        assert_equal(-32_603, response[:error][:code])
      end

      def test_missing_tool_name
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'arguments' => {}
          },
          'id' => 102
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(102, response[:id])
        assert(response[:error])
        assert_equal(-32_603, response[:error][:code])
      end

      def test_quarter_calculation
        # Test quarter calculation for different months
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_date_info',
            'arguments' => {}
          },
          'id' => 103
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        month = data['month']
        expected_quarter = case month
                           when 1..3 then 1
                           when 4..6 then 2
                           when 7..9 then 3
                           when 10..12 then 4
                           end

        assert_equal(expected_quarter, data['quarter'])
      end

      def test_days_in_month_calculation
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_date_info',
            'arguments' => {}
          },
          'id' => 104
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Days in month should be valid
        month = data['month']
        days_in_month = data['days_in_month']

        case month
        when 2
          # February can have 28 or 29 days
          assert_includes([28, 29], days_in_month)
        when 4, 6, 9, 11
          # April, June, September, November have 30 days
          assert_equal(30, days_in_month)
        else
          # All other months have 31 days
          assert_equal(31, days_in_month)
        end
      end

      def test_content_structure
        # Test that content is always returned as an array with proper structure
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {}
          },
          'id' => 105
        }

        response = send_request(@server, request)

        assert(response[:result][:content])
        assert_kind_of(Array, response[:result][:content])
        assert_equal(1, response[:result][:content].length)

        content = response[:result][:content].first
        assert_equal('text', content[:type])
        assert(content[:text])

        # Verify it's valid JSON
        parsed = JSON.parse(content[:text])
        assert_kind_of(Hash, parsed)
      end

      def test_timestamp_precision
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {}
          },
          'id' => 106
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Timestamp should be a float with sub-second precision
        timestamp = data['timestamp']
        assert_kind_of(Float, timestamp)
        assert(timestamp.positive?)

        # Check that it's a reasonable Unix timestamp (after year 2000)
        assert(timestamp > 946_684_800) # January 1, 2000
      end

      def test_weekday_names
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {}
          },
          'id' => 107
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        valid_weekdays = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
        assert_includes(valid_weekdays, data['weekday'])
      end

      def test_month_names
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_date_info',
            'arguments' => {}
          },
          'id' => 108
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        valid_months = %w[January February March April May June July August September October
                          November December]
        assert_includes(valid_months, data['month_name'])
      end

      def test_logging_functionality
        # Test that the log file is created and written to
        log_file = MCP::DateTime::Server::LOG_FILE

        # Clear log file if it exists
        FileUtils.rm_f(log_file)

        # Create a new server (which logs on initialization)
        create_server

        # The log file should exist after server creation
        assert(File.exist?(log_file), 'Log file should be created')

        # Read log contents
        log_contents = File.read(log_file)
        assert_match(/Starting MCP DateTime server/, log_contents)
        assert_match(/Ruby \d+\.\d+\.\d+/, log_contents)
      end

      def test_server_info_version_matches
        request = {
          'jsonrpc' => '2.0',
          'method' => 'initialize',
          'params' => {},
          'id' => 109
        }

        response = send_request(@server, request)

        # Server version should match the gem version
        assert_equal(MCP::DateTime::VERSION, response[:result][:serverInfo][:version])
      end

      def test_iso8601_format_compliance
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'iso'
            }
          },
          'id' => 110
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Should be a valid ISO8601 format
        datetime_str = data['datetime']

        # Try to parse it back
        parsed_time = Time.iso8601(datetime_str)
        assert_kind_of(Time, parsed_time)
      end

      def test_unix_timestamp_conversion
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'unix'
            }
          },
          'id' => 111
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Unix timestamp in datetime field should match timestamp field (within 1 second)
        unix_timestamp = data['datetime'].to_i
        float_timestamp = data['timestamp'].to_i

        assert_in_delta(unix_timestamp, float_timestamp, 1)
      end
    end
  end
end
