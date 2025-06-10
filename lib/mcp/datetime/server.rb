# typed: false
# frozen_string_literal: true

module MCP
  module DateTime
    class Server
      LOG_FILE = "/tmp/mcp_datetime_debug.log"

      def initialize
        @server_info = {
          name: "mcp-datetime-ruby",
          version: VERSION,
        }
        $stderr.sync = true
        $stdout.sync = true

        # Initialize logging
        log("Starting MCP DateTime server (Ruby #{RUBY_VERSION})")
        log("Script location: #{__FILE__}")
        log("Working directory: #{Dir.pwd}")
      end

      def run
        $stderr.puts "[MCP::DateTime] Starting server..."

        loop do
          # Read JSON-RPC request from stdin
          line = $stdin.gets

          # Exit gracefully on EOF
          if line.nil?
            log("EOF received, shutting down gracefully")
            $stderr.puts "[MCP::DateTime] EOF received, shutting down gracefully"
            break
          end

          # Skip empty lines
          next if line.strip.empty?

          request = JSON.parse(line.strip)
          log("Received request: #{request["method"]}")
          $stderr.puts "[MCP::DateTime] Received request: #{request["method"]}"

          response = handle_request(request)

          # Write JSON-RPC response to stdout only if there's an id (not a notification)
          if request["id"]
            $stdout.puts(JSON.generate(response))
            $stdout.flush
          end
        rescue JSON::ParserError => e
          log("Parse error: #{e.message}")
          error_response = {
            jsonrpc: "2.0",
            error: {
              code: -32700,
              message: "Parse error: #{e.message}",
            },
            id: nil,
          }
          $stdout.puts(JSON.generate(error_response))
          $stdout.flush
        rescue Interrupt
          log("Interrupted, shutting down")
          $stderr.puts "[MCP::DateTime] Interrupted, shutting down"
          break
        rescue StandardError => e
          log("Error: #{e.message}")
          log(e.backtrace.join("\n"))
          $stderr.puts "[MCP::DateTime] Error: #{e.message}"
          $stderr.puts e.backtrace.join("\n")
        end

        log("Server stopped")
        $stderr.puts "[MCP::DateTime] Server stopped"
      end

      private

      def log(message)
        File.open(LOG_FILE, "a") do |f|
          f.puts "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}"
        end
      rescue => e
        $stderr.puts "Failed to write to log: #{e.message}"
      end

      def handle_request(request)
        method = request["method"]
        params = request["params"] || {}
        id = request["id"]

        # Handle notifications (no response needed)
        if method == "notifications/initialized"
          log("Client initialized notification received")
          $stderr.puts "[MCP::DateTime] Client initialized notification received"
          return
        end

        result = case method
        when "initialize"
          handle_initialize(params)
        when "tools/list"
          handle_list_tools
        when "tools/call"
          handle_call_tool(params)
        else
          raise "Unknown method: #{method}"
        end

        {
          jsonrpc: "2.0",
          result:,
          id:,
        }
      rescue StandardError => e
        {
          jsonrpc: "2.0",
          error: {
            code: -32603,
            message: e.message,
          },
          id:,
        }
      end

      def handle_initialize(params)
        {
          protocolVersion: "2024-11-05",
          capabilities: {
            tools: {},
          },
          serverInfo: @server_info,
        }
      end

      def handle_list_tools
        {
          tools: [
            {
              name: "get_current_datetime",
              description: "Get the current date and time",
              inputSchema: {
                type: "object",
                properties: {
                  format: {
                    type: "string",
                    description: "Optional datetime format",
                    enum: ["iso", "human", "date_only", "time_only", "unix"],
                  },
                  timezone: {
                    type: "string",
                    description: 'Optional timezone (e.g., "America/New_York", "Europe/London")',
                  },
                },
              },
            },
            {
              name: "get_date_info",
              description: "Get detailed information about the current date",
              inputSchema: {
                type: "object",
                properties: {},
              },
            },
          ],
        }
      end

      def handle_call_tool(params)
        tool_name = params["name"]
        arguments = params["arguments"] || {}

        case tool_name
        when "get_current_datetime"
          get_current_datetime(arguments)
        when "get_date_info"
          get_date_info
        else
          raise "Unknown tool: #{tool_name}"
        end
      end

      def get_current_datetime(arguments)
        format_type = arguments["format"] || "iso"
        timezone = arguments["timezone"]

        # Get current time
        now = if timezone
          ENV["TZ"] = timezone
          Time.now
        else
          Time.now
        end

        formatted = case format_type
        when "iso"
          now.iso8601
        when "human"
          now.strftime("%B %d, %Y at %I:%M %p")
        when "date_only"
          now.strftime("%Y-%m-%d")
        when "time_only"
          now.strftime("%H:%M:%S")
        when "unix"
          now.to_i.to_s
        else
          now.iso8601
        end

        {
          content: [
            {
              type: "text",
              text: JSON.pretty_generate({
                datetime: formatted,
                timestamp: now.to_f,
                year: now.year,
                month: now.month,
                day: now.day,
                hour: now.hour,
                minute: now.min,
                second: now.sec,
                weekday: now.strftime("%A"),
                timezone: now.zone,
              }),
            },
          ],
        }
      end

      def get_date_info
        now = Time.now
        today = Date.today

        {
          content: [
            {
              type: "text",
              text: JSON.pretty_generate({
                date: today.to_s,
                year: today.year,
                month: today.month,
                month_name: today.strftime("%B"),
                day: today.day,
                weekday: today.strftime("%A"),
                weekday_number: today.wday,
                day_of_year: today.yday,
                week_of_year: today.cweek,
                quarter: (today.month - 1) / 3 + 1,
                is_weekend: [0, 6].include?(today.wday),
                is_leap_year: today.leap?,
                days_in_month: Date.new(today.year, today.month, -1).day,
                timezone: now.zone,
              }),
            },
          ],
        }
      end
    end
  end
end
