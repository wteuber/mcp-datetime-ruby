# typed: false
# frozen_string_literal: true

module MCP
  module DateTime
    # Tool definitions for the MCP DateTime server
    module Tools
      def datetime_tool_definition
        {
          name: 'get_current_datetime',
          description: 'Get the current date and time',
          inputSchema: {
            type: 'object',
            properties: {
              format: {
                type: 'string',
                description: 'Optional datetime format',
                enum: %w[iso human date_only time_only unix]
              },
              timezone: {
                type: 'string',
                description: 'Optional timezone (e.g., "America/New_York", "Europe/London")'
              }
            }
          }
        }
      end

      def date_info_tool_definition
        {
          name: 'get_date_info',
          description: 'Get detailed information about the current date',
          inputSchema: {
            type: 'object',
            properties: {}
          }
        }
      end
    end
  end
end
