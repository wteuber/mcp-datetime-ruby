# typed: false
# frozen_string_literal: true

require_relative 'tools'

module MCP
  module DateTime
    # MCP DateTime Server implementation
    # Provides datetime tools via the Model Context Protocol
    class Server
      include Tools

      LOG_FILE = '/tmp/mcp_datetime_debug.log'

      def initialize
        @server_info = {
          name: 'mcp-datetime-ruby',
          version: VERSION
        }
        setup_io_streams
        setup_signal_handlers
        log_startup_info
      end

      def run
        warn '[MCP::DateTime] Starting server...'
        process_requests
        warn '[MCP::DateTime] Server stopped'
      end

      private

      def setup_io_streams
        $stderr.sync = true
        $stdout.sync = true
      end

      def setup_signal_handlers
        Signal.trap('INT') { exit(0) }
        Signal.trap('TERM') { exit(0) }
      end

      def log_startup_info
        log("Starting MCP DateTime server (Ruby #{RUBY_VERSION})")
        log("Script location: #{__FILE__}")
        log("Working directory: #{Dir.pwd}")
        log("Environment: #{ENV.to_h}")
      end

      def process_requests
        loop do
          line = read_request
          next unless line

          handle_request_line(line)
        rescue JSON::ParserError => e
          handle_parse_error(e)
        rescue Interrupt
          handle_interrupt
        rescue StandardError => e
          handle_error(e)
        end
      end

      def read_request
        line = $stdin.gets
        if line.nil?
          handle_eof
          return nil
        end
        line.strip.empty? ? nil : line
      end

      def handle_eof
        log('EOF received, shutting down gracefully')
        warn '[MCP::DateTime] EOF received, shutting down gracefully'
        exit(0)
      end

      def handle_request_line(line)
        request = JSON.parse(line.strip)
        log("Received request: #{request['method']}")
        warn "[MCP::DateTime] Received request: #{request['method']}"

        response = handle_request(request)
        send_response(request, response)
      end

      def send_response(request, response)
        return unless request['id'] && response

        $stdout.puts(JSON.generate(response))
        $stdout.flush
      end

      def handle_parse_error(error)
        log("Parse error: #{error.message}")
        error_response = build_error_response(-32_700, "Parse error: #{error.message}")
        $stdout.puts(JSON.generate(error_response))
        $stdout.flush
      end

      def handle_interrupt
        log('Interrupted, shutting down')
        warn '[MCP::DateTime] Interrupted, shutting down'
        exit(0)
      end

      def handle_error(error)
        log("Error: #{error.message}")
        log(error.backtrace.join("\n"))
        warn "[MCP::DateTime] Error: #{error.message}"
        warn error.backtrace.join("\n")
      end

      def log(message)
        File.open(LOG_FILE, 'a') do |f|
          f.puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{message}"
        end
      rescue StandardError => e
        warn "Failed to write to log: #{e.message}"
      end

      def handle_request(request)
        method = request['method']
        params = request['params'] || {}
        id = request['id']

        return handle_notification(method) if notification?(method)

        result = dispatch_method(method, params)
        build_success_response(result, id)
      rescue StandardError => e
        build_error_response(-32_603, e.message, id)
      end

      def notification?(method)
        method == 'notifications/initialized'
      end

      def handle_notification(method)
        return unless method == 'notifications/initialized'

        log('Client initialized notification received')
        warn '[MCP::DateTime] Client initialized notification received'
        nil
      end

      def dispatch_method(method, params)
        case method
        when 'initialize'
          handle_initialize(params)
        when 'tools/list'
          handle_list_tools
        when 'tools/call'
          handle_call_tool(params)
        else
          raise "Unknown method: #{method}"
        end
      end

      def build_success_response(result, id)
        {
          jsonrpc: '2.0',
          result:,
          id:
        }
      end

      def build_error_response(code, message, id = nil)
        {
          jsonrpc: '2.0',
          error: {
            code:,
            message:
          },
          id:
        }
      end

      def handle_initialize(_params)
        {
          protocolVersion: '2024-11-05',
          capabilities: {
            tools: {
              listChanged: false
            }
          },
          serverInfo: @server_info
        }
      end

      def handle_list_tools
        {
          tools: [
            datetime_tool_definition,
            date_info_tool_definition
          ]
        }
      end

      def handle_call_tool(params)
        tool_name = params['name']
        arguments = params['arguments'] || {}

        case tool_name
        when 'get_current_datetime'
          current_datetime(arguments)
        when 'get_date_info'
          date_info
        else
          raise "Unknown tool: #{tool_name}"
        end
      end

      def current_datetime(arguments)
        format_type = arguments['format'] || 'iso'
        timezone = arguments['timezone']

        now = get_time_in_timezone(timezone)
        formatted = format_datetime(now, format_type)

        build_content_response(datetime_data(now, formatted))
      end

      def get_time_in_timezone(timezone)
        ENV['TZ'] = timezone if timezone
        Time.now
      end

      def format_datetime(time, format_type)
        case format_type
        when 'human' then time.strftime('%B %d, %Y at %I:%M %p')
        when 'date_only' then time.strftime('%Y-%m-%d')
        when 'time_only' then time.strftime('%H:%M:%S')
        when 'unix' then time.to_i.to_s
        else time.iso8601
        end
      end

      def datetime_data(time, formatted)
        {
          datetime: formatted,
          timestamp: time.to_f,
          year: time.year,
          month: time.month,
          day: time.day,
          hour: time.hour,
          minute: time.min,
          second: time.sec,
          weekday: time.strftime('%A'),
          timezone: time.zone
        }
      end

      def date_info
        now = Time.now
        today = Date.today

        build_content_response(date_info_data(today, now))
      end

      def date_info_data(date, time)
        {
          date: date.to_s,
          year: date.year,
          month: date.month,
          month_name: date.strftime('%B'),
          day: date.day,
          weekday: date.strftime('%A'),
          weekday_number: date.wday,
          day_of_year: date.yday,
          week_of_year: date.cweek,
          quarter: ((date.month - 1) / 3) + 1,
          is_weekend: [0, 6].include?(date.wday),
          is_leap_year: date.leap?,
          days_in_month: Date.new(date.year, date.month, -1).day,
          timezone: time.zone
        }
      end

      def build_content_response(data)
        {
          content: [
            {
              type: 'text',
              text: JSON.pretty_generate(data)
            }
          ]
        }
      end
    end
  end
end
