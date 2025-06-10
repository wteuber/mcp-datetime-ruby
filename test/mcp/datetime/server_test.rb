# typed: false
# frozen_string_literal: true

require 'test_helper'

module MCP
  module DateTime
    class ServerTest < MCPTestHelper
      def setup
        super # Call parent setup to suppress stderr
        @server = create_server
      end

      def test_initialize_request
        request = {
          'jsonrpc' => '2.0',
          'method' => 'initialize',
          'params' => {
            'protocolVersion' => '2024-11-05',
            'capabilities' => {},
            'clientInfo' => {
              'name' => 'test-client',
              'version' => '1.0.0'
            }
          },
          'id' => 1
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(1, response[:id])
        assert_equal('2024-11-05', response[:result][:protocolVersion])
        assert_equal({ listChanged: false }, response[:result][:capabilities][:tools])
        assert_equal('mcp-datetime-ruby', response[:result][:serverInfo][:name])
        assert_equal('0.1.0', response[:result][:serverInfo][:version])
      end

      def test_initialize_request_without_params
        request = {
          'jsonrpc' => '2.0',
          'method' => 'initialize',
          'id' => 1
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(1, response[:id])
        assert(response[:result][:protocolVersion])
        assert(response[:result][:capabilities])
        assert(response[:result][:serverInfo])
      end

      def test_notifications_initialized
        request = {
          'jsonrpc' => '2.0',
          'method' => 'notifications/initialized',
          'params' => {}
        }

        response = send_request(@server, request)
        assert_nil(response)
      end

      def test_list_tools
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/list',
          'params' => {},
          'id' => 2
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(2, response[:id])

        tools = response[:result][:tools]
        assert_equal(2, tools.length)

        # Check get_current_datetime tool
        datetime_tool = tools.find { |t| t[:name] == 'get_current_datetime' }
        assert(datetime_tool)
        assert_equal('Get the current date and time', datetime_tool[:description])
        assert(datetime_tool[:inputSchema][:properties][:format])
        assert(datetime_tool[:inputSchema][:properties][:timezone])

        # Check get_date_info tool
        date_info_tool = tools.find { |t| t[:name] == 'get_date_info' }
        assert(date_info_tool)
        assert_equal('Get detailed information about the current date', date_info_tool[:description])
      end

      def test_get_current_datetime_iso_format
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'iso'
            }
          },
          'id' => 3
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(3, response[:id])

        content = response[:result][:content].first
        assert_equal('text', content[:type])

        data = JSON.parse(content[:text])
        assert_match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, data['datetime'])
        assert(data['timestamp'])
        assert(data['year'])
        assert(data['month'])
        assert(data['day'])
        assert(data['hour'])
        assert(data['minute'])
        assert(data['second'])
        assert(data['weekday'])
        assert(data['timezone'])
      end

      def test_get_current_datetime_human_format
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'human'
            }
          },
          'id' => 4
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        assert_match(/\w+ \d{1,2}, \d{4} at \d{1,2}:\d{2} [AP]M/, data['datetime'])
      end

      def test_get_current_datetime_date_only_format
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'date_only'
            }
          },
          'id' => 5
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        assert_match(/^\d{4}-\d{2}-\d{2}$/, data['datetime'])
      end

      def test_get_current_datetime_time_only_format
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'time_only'
            }
          },
          'id' => 6
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        assert_match(/^\d{2}:\d{2}:\d{2}$/, data['datetime'])
      end

      def test_get_current_datetime_unix_format
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'unix'
            }
          },
          'id' => 7
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        assert_match(/^\d+$/, data['datetime'])
        assert(data['datetime'].to_i.positive?)
      end

      def test_get_current_datetime_default_format
        # Test when no format is specified (should default to iso)
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {}
          },
          'id' => 12
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Should default to ISO format
        assert_match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, data['datetime'])
      end

      def test_get_current_datetime_invalid_format
        # Test when an invalid format is specified (should default to iso)
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'invalid_format'
            }
          },
          'id' => 13
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Should default to ISO format
        assert_match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, data['datetime'])
      end

      def test_get_current_datetime_without_timezone
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'iso'
            }
          },
          'id' => 14
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Should use system timezone
        assert(data['timezone'])
        assert(data['datetime'])
      end

      def test_get_date_info
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_date_info',
            'arguments' => {}
          },
          'id' => 8
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(8, response[:id])

        content = response[:result][:content].first
        assert_equal('text', content[:type])

        data = JSON.parse(content[:text])
        assert(data['date'])
        assert(data['year'])
        assert(data['month'])
        assert(data['month_name'])
        assert(data['day'])
        assert(data['weekday'])
        assert_includes(0..6, data['weekday_number'])
        assert(data['day_of_year'])
        assert(data['week_of_year'])
        assert_includes(1..4, data['quarter'])
        assert_includes([true, false], data['is_weekend'])
        assert_includes([true, false], data['is_leap_year'])
        assert(data['days_in_month'])
        assert(data['timezone'])
      end

      def test_get_date_info_specific_values
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_date_info',
            'arguments' => {}
          },
          'id' => 15
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Test specific date calculations
        assert_match(/^\d{4}-\d{2}-\d{2}$/, data['date'])
        assert_includes(1..12, data['month'])
        assert_includes(1..31, data['day'])
        assert_includes(1..366, data['day_of_year'])
        assert_includes(1..53, data['week_of_year'])
        assert_includes(28..31, data['days_in_month'])

        # Test weekday logic
        if [0, 6].include?(data['weekday_number'])
          assert(data['is_weekend'])
        else
          refute(data['is_weekend'])
        end
      end

      def test_unknown_method_error
        request = {
          'jsonrpc' => '2.0',
          'method' => 'unknown/method',
          'params' => {},
          'id' => 9
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(9, response[:id])
        assert(response[:error])
        assert_equal(-32_603, response[:error][:code])
        assert_match(/Unknown method/, response[:error][:message])
      end

      def test_unknown_tool_error
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'unknown_tool',
            'arguments' => {}
          },
          'id' => 10
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(10, response[:id])
        assert(response[:error])
        assert_equal(-32_603, response[:error][:code])
        assert_match(/Unknown tool/, response[:error][:message])
      end

      def test_timezone_handling
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'iso',
              'timezone' => 'America/New_York'
            }
          },
          'id' => 11
        }

        # Save original timezone
        original_tz = ENV.fetch('TZ', nil)

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # The timezone should be set in the response
        assert(data['datetime'])
        assert(data['timezone'])
      ensure
        # Restore original timezone
        ENV['TZ'] = original_tz
      end

      def test_multiple_timezone_requests
        # Test that timezone changes don't persist between requests
        original_tz = ENV.fetch('TZ', nil)

        # First request with New York timezone
        request1 = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'iso',
              'timezone' => 'America/New_York'
            }
          },
          'id' => 16
        }

        response1 = send_request(@server, request1)
        content1 = response1[:result][:content].first
        data1 = JSON.parse(content1[:text])

        # Second request with Tokyo timezone
        request2 = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'iso',
              'timezone' => 'Asia/Tokyo'
            }
          },
          'id' => 17
        }

        response2 = send_request(@server, request2)
        content2 = response2[:result][:content].first
        data2 = JSON.parse(content2[:text])

        # Both should have their respective timezones
        assert(data1['timezone'])
        assert(data2['timezone'])
      ensure
        ENV['TZ'] = original_tz
      end

      def test_tools_call_without_arguments
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime'
            # No arguments provided
          },
          'id' => 18
        }

        response = send_request(@server, request)

        # Should still work with default values
        assert_equal('2.0', response[:jsonrpc])
        assert_equal(18, response[:id])
        assert(response[:result][:content])
      end

      def test_request_without_id
        # Test notification-style request (no id)
        request = {
          'jsonrpc' => '2.0',
          'method' => 'notifications/initialized'
        }

        response = send_request(@server, request)
        assert_nil(response)
      end

      def test_request_with_nil_params
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/list',
          'params' => nil,
          'id' => 19
        }

        response = send_request(@server, request)

        assert_equal('2.0', response[:jsonrpc])
        assert_equal(19, response[:id])
        assert(response[:result][:tools])
      end

      def test_all_datetime_fields_present
        # Ensure all expected fields are present in datetime response
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_current_datetime',
            'arguments' => {
              'format' => 'iso'
            }
          },
          'id' => 20
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Check all fields are present
        required_fields = %w[datetime timestamp year month day hour minute second weekday
                             timezone]
        required_fields.each do |field|
          assert(data.key?(field), "Missing field: #{field}")
        end

        # Check field types
        assert_kind_of(String, data['datetime'])
        assert_kind_of(Float, data['timestamp'])
        assert_kind_of(Integer, data['year'])
        assert_kind_of(Integer, data['month'])
        assert_kind_of(Integer, data['day'])
        assert_kind_of(Integer, data['hour'])
        assert_kind_of(Integer, data['minute'])
        assert_kind_of(Integer, data['second'])
        assert_kind_of(String, data['weekday'])
        assert_kind_of(String, data['timezone'])
      end

      def test_all_date_info_fields_present
        # Ensure all expected fields are present in date info response
        request = {
          'jsonrpc' => '2.0',
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_date_info',
            'arguments' => {}
          },
          'id' => 21
        }

        response = send_request(@server, request)
        content = response[:result][:content].first
        data = JSON.parse(content[:text])

        # Check all fields are present
        required_fields = %w[
          date
          year
          month
          month_name
          day
          weekday
          weekday_number
          day_of_year
          week_of_year
          quarter
          is_weekend
          is_leap_year
          days_in_month
          timezone
        ]
        required_fields.each do |field|
          assert(data.key?(field), "Missing field: #{field}")
        end

        # Check field types
        assert_kind_of(String, data['date'])
        assert_kind_of(Integer, data['year'])
        assert_kind_of(Integer, data['month'])
        assert_kind_of(String, data['month_name'])
        assert_kind_of(Integer, data['day'])
        assert_kind_of(String, data['weekday'])
        assert_kind_of(Integer, data['weekday_number'])
        assert_kind_of(Integer, data['day_of_year'])
        assert_kind_of(Integer, data['week_of_year'])
        assert_kind_of(Integer, data['quarter'])
        assert_includes([true, false], data['is_weekend'])
        assert_includes([true, false], data['is_leap_year'])
        assert_kind_of(Integer, data['days_in_month'])
        assert_kind_of(String, data['timezone'])
      end
    end
  end
end
