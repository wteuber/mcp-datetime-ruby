# MCP DateTime Ruby

A Ruby implementation of an MCP (Model Context Protocol) server that provides datetime tools for AI assistants. This server enables AI assistants to get current date/time information and detailed date information in various formats.

## Features

- Get current date and time in multiple formats (ISO, human-readable, Unix timestamp, etc.)
- Support for timezone conversions
- Detailed date information (weekday, quarter, leap year status, etc.)
- Full MCP protocol compliance
- Automatic executable installation via RubyGems plugin

## Requirements

- Ruby 3.1.0 or higher
- Bundler

## Installation

### From RubyGems (Once Published)

```bash
gem install mcp-datetime-ruby
```

The gem will automatically install an executable at `~/bin/mcp-datetime-ruby` during installation.

### Local Installation (Development)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/wteuber/mcp-datetime-ruby.git
   cd mcp-datetime-ruby
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Build and install the gem locally**:
   ```bash
   gem build mcp-datetime-ruby.gemspec
   gem install ./mcp-datetime-ruby-0.1.0.gem
   ```

   This will automatically create the executable at `~/bin/mcp-datetime-ruby`.

4. **Or run directly without installing**:
   ```bash
   # Run directly from the repository
   ./bin/mcp-datetime-ruby
   
   # Or with bundle exec
   bundle exec ruby bin/mcp-datetime-ruby
   ```

### Verifying Installation

After installation, verify the executable is available:

```bash
# Check if the executable exists
which mcp-datetime-ruby

# Or if ~/bin is not in your PATH
ls ~/bin/mcp-datetime-ruby
```

## Configuration

### Adding to Cursor

To use this MCP server with Cursor:

1. **Open your MCP configuration file**:
   ```bash
   # Create the file if it doesn't exist
   touch ~/.cursor/mcp.json
   ```

2. **Add the datetime server configuration**:

   If `~/bin` is in your PATH:
   ```json
   {
     "mcpServers": {
       "datetime": {
         "command": "mcp-datetime-ruby"
       }
     }
   }
   ```

   If you need to use the full path:
   ```json
   {
     "mcpServers": {
       "datetime": {
         "command": "/Users/yourusername/bin/mcp-datetime-ruby"
       }
     }
   }
   ```

   If running from the repository directly:
   ```json
   {
     "mcpServers": {
       "datetime": {
         "command": "/path/to/mcp-datetime-ruby/bin/mcp-datetime-ruby"
       }
     }
   }
   ```

3. **If you have existing MCP servers**, add to the existing configuration:
   ```json
   {
     "mcpServers": {
       "existing-server": {
         "command": "existing-command"
       },
       "datetime": {
         "command": "mcp-datetime-ruby"
       }
     }
   }
   ```

4. **Restart Cursor** for the changes to take effect.

5. **Verify the server is working** by asking the AI to "get the current time" or "what's today's date".

## Available Tools

### `get_current_datetime`

Get the current date and time in various formats.

**Parameters:**
- `format` (optional): Output format
  - `iso` (default): ISO 8601 format (e.g., "2024-01-15T14:30:45-05:00")
  - `human`: Human-readable format (e.g., "January 15, 2024 at 02:30 PM")
  - `date_only`: Date only (e.g., "2024-01-15")
  - `time_only`: Time only (e.g., "14:30:45")
  - `unix`: Unix timestamp (e.g., "1705342245")
- `timezone` (optional): IANA timezone name (e.g., "America/New_York", "Europe/London", "Asia/Tokyo")

**Example Response:**
```json
{
  "datetime": "2024-01-15T14:30:45-05:00",
  "timestamp": 1705342245.123456,
  "year": 2024,
  "month": 1,
  "day": 15,
  "hour": 14,
  "minute": 30,
  "second": 45,
  "weekday": "Monday",
  "timezone": "EST"
}
```

### `get_date_info`

Get detailed information about the current date.

**Parameters:** None

**Example Response:**
```json
{
  "date": "2024-01-15",
  "year": 2024,
  "month": 1,
  "month_name": "January",
  "day": 15,
  "weekday": "Monday",
  "weekday_number": 1,
  "day_of_year": 15,
  "week_of_year": 3,
  "quarter": 1,
  "is_weekend": false,
  "is_leap_year": true,
  "days_in_month": 31,
  "timezone": "EST"
}
```

## Development

### Setup

After cloning the repository:

```bash
# Install dependencies
bundle install

# Run tests to verify everything is working
bundle exec rake test
```

### Code Style

This project uses RuboCop for code style enforcement. Run RuboCop to check for style violations:

```bash
# Check for style violations
bundle exec rubocop

# Auto-correct correctable violations
bundle exec rubocop -a

# Auto-correct with more aggressive corrections
bundle exec rubocop -A
```

The project includes a `.rubocop.yml` configuration file that customizes the rules for this codebase.

### Running Tests

The gem includes comprehensive tests using Minitest:

```bash
# Run unit tests only (default)
bundle exec rake test

# Run integration tests only
bundle exec rake integration

# Run all tests (unit + integration)
bundle exec rake test_all

# Run tests with verbose output
bundle exec rake test TESTOPTS="--verbose"

# Run a specific test file
bundle exec ruby -Ilib:test test/mcp/datetime/server_test.rb
```

The test suite includes:
- Unit tests for all MCP protocol methods
- Tests for each datetime format and timezone handling
- Edge case and error handling tests
- RubyGems plugin tests
- Integration tests for full server communication

### Building the Gem

```bash
# Build the gem
gem build mcp-datetime-ruby.gemspec

# Install locally for testing
gem install ./mcp-datetime-ruby-0.1.0.gem
```

### Debugging

The server logs debug information to `/tmp/mcp_datetime_debug.log`. You can tail this file to see server activity:

```bash
tail -f /tmp/mcp_datetime_debug.log
```

## Uninstalling

### Uninstall the Gem

```bash
# Uninstall the gem (this will also remove the executable from ~/bin)
gem uninstall mcp-datetime-ruby

# If multiple versions are installed
gem uninstall mcp-datetime-ruby --all
```

### Remove from Cursor Configuration

Remove the datetime server entry from `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    // Remove this entire "datetime" section
    "datetime": {
      "command": "mcp-datetime-ruby"
    }
  }
}
```

### Clean Up Development Files

If you cloned the repository:

```bash
# Remove the cloned repository
rm -rf /path/to/mcp-datetime-ruby

# Remove any locally built gem files
rm mcp-datetime-ruby-*.gem
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wteuber/mcp-datetime-ruby.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Write tests for your changes
4. Make your changes and ensure all tests pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin feature/my-new-feature`)
7. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
