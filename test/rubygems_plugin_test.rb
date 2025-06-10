# typed: false
# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'tmpdir'

class RubygemsPluginTest < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir
    @home_bin_dir = File.join(@temp_dir, 'bin')
    @executable_path = File.join(@home_bin_dir, 'mcp-datetime-ruby')
    @gem_dir = File.expand_path('..', __dir__)
  end

  def teardown
    FileUtils.rm_rf(@temp_dir) if File.exist?(@temp_dir)
  end

  def test_post_install_creates_executable
    # Mock the installer
    installer = MockInstaller.new('mcp-datetime-ruby', @gem_dir)

    # Temporarily override home directory
    with_temp_home(@temp_dir) do
      # Load and execute the plugin
      load File.expand_path('../lib/rubygems_plugin.rb', __dir__)

      # Trigger the post_install hook
      Gem.post_install_hooks.each do |hook|
        hook.call(installer)
      end
    end

    # Check that executable was created
    assert File.exist?(@executable_path), 'Executable should be created'
    assert File.executable?(@executable_path), 'File should be executable'

    # Check executable content
    content = File.read(@executable_path)
    assert_match(/^#!.*ruby/, content, 'Should have ruby shebang')
    assert_match(%r{require.*mcp/datetime}, content, 'Should require the gem')
    assert_match(/MCP::DateTime::Server\.new\.run/, content, 'Should run the server')
  end

  def test_post_install_updates_existing_executable
    # Create an existing executable
    FileUtils.mkdir_p(@home_bin_dir)
    File.write(@executable_path, 'old content')

    installer = MockInstaller.new('mcp-datetime-ruby', @gem_dir)

    with_temp_home(@temp_dir) do
      load File.expand_path('../lib/rubygems_plugin.rb', __dir__)

      Gem.post_install_hooks.each do |hook|
        hook.call(installer)
      end
    end

    # Check that executable was updated
    content = File.read(@executable_path)
    refute_equal 'old content', content
    assert_match(/MCP::DateTime::Server/, content)
  end

  def test_post_install_skips_other_gems
    installer = MockInstaller.new('other-gem', '/path/to/other/gem')

    with_temp_home(@temp_dir) do
      load File.expand_path('../lib/rubygems_plugin.rb', __dir__)

      Gem.post_install_hooks.each do |hook|
        hook.call(installer)
      end
    end

    # Should not create executable for other gems
    refute File.exist?(@executable_path)
  end

  def test_pre_uninstall_removes_executable
    # Create the executable first
    FileUtils.mkdir_p(@home_bin_dir)
    File.write(@executable_path, 'test content')

    uninstaller = MockUninstaller.new('mcp-datetime-ruby')

    with_temp_home(@temp_dir) do
      load File.expand_path('../lib/rubygems_plugin.rb', __dir__)

      Gem.pre_uninstall_hooks.each do |hook|
        hook.call(uninstaller)
      end
    end

    # Check that executable was removed
    refute File.exist?(@executable_path), 'Executable should be removed'
  end

  def test_pre_uninstall_handles_missing_executable
    # Don't create the executable
    uninstaller = MockUninstaller.new('mcp-datetime-ruby')

    with_temp_home(@temp_dir) do
      load File.expand_path('../lib/rubygems_plugin.rb', __dir__)

      # Should not raise error
      Gem.pre_uninstall_hooks.each do |hook|
        hook.call(uninstaller)
      end
    end
  end

  private

  def with_temp_home(temp_dir)
    original_home = ENV['HOME']
    ENV['HOME'] = temp_dir
    yield
  ensure
    ENV['HOME'] = original_home
  end

  # Mock classes for testing
  class MockInstaller
    attr_reader :spec

    def initialize(name, gem_dir)
      @spec = MockSpec.new(name, gem_dir)
    end
  end

  class MockUninstaller
    attr_reader :spec

    def initialize(name)
      @spec = MockSpec.new(name, nil)
    end
  end

  class MockSpec
    attr_reader :name, :gem_dir

    def initialize(name, gem_dir)
      @name = name
      @gem_dir = gem_dir
    end
  end
end
