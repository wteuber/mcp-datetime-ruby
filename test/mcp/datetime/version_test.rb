# typed: false
# frozen_string_literal: true

require 'test_helper'

module MCP
  module DateTime
    class VersionTest < Minitest::Test
      def test_version_is_defined
        refute_nil(MCP::DateTime::VERSION)
      end

      def test_version_format
        assert_match(/^\d+\.\d+\.\d+$/, MCP::DateTime::VERSION)
      end

      def test_current_version
        assert_equal('0.1.0', MCP::DateTime::VERSION)
      end
    end
  end
end
