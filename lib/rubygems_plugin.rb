# frozen_string_literal: true

require 'rubygems'
require 'fileutils'

# This plugin creates an executable file after gem installation
Gem.post_install do |installer|
  next unless installer.spec.name == 'mcp-datetime-ruby'

  # Get the gem's installation directory
  gem_dir = installer.spec.gem_dir

  # Create the executable content with the proper paths
  executable_content = <<~RUBY
    #!#{Gem.ruby}
    # frozen_string_literal: true

    # Add the gem's lib directory to the load path
    $LOAD_PATH.unshift("#{gem_dir}/lib")

    require 'json'
    require 'date'
    require 'time'
    require 'mcp/datetime/version'
    require 'mcp/datetime/server'

    # Run the server
    MCP::DateTime::Server.new.run
  RUBY

  # Determine the bin directory in user's home
  home_bin_dir = File.expand_path('~/bin')
  executable_path = File.join(home_bin_dir, 'mcp-datetime-ruby')

  # Create the bin directory if it doesn't exist
  FileUtils.mkdir_p(home_bin_dir) unless File.directory?(home_bin_dir)

  # Check if executable already exists
  if File.exist?(executable_path)
    puts "Updating existing executable: #{executable_path}"
  else
    puts "Creating new executable: #{executable_path}"
  end

  # Write the executable file
  File.write(executable_path, executable_content)

  # Make it executable
  File.chmod(0o755, executable_path)

  puts "Executable ready at: #{executable_path}"
  puts 'Make sure ~/bin is in your PATH to use the executable' unless ENV['PATH'].include?(home_bin_dir)
end

# Clean up the executable on uninstall
Gem.pre_uninstall do |uninstaller|
  next unless uninstaller.spec.name == 'mcp-datetime-ruby'

  executable_path = File.expand_path('~/bin/mcp-datetime-ruby')

  if File.exist?(executable_path)
    File.delete(executable_path)
    puts "Removed executable: #{executable_path}"
  end
end
