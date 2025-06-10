# typed: false
# frozen_string_literal: true

require "json"
require "time"
require "date"
require_relative "datetime/version"
require_relative "datetime/server"

module MCP
  module DateTime
    class Error < StandardError; end
  end
end
