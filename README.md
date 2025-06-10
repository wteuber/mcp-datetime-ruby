# MCP DateTime Ruby

A Ruby implementation of an MCP (Model Context Protocol) server that provides datetime tools for AI assistants.

## Installation

### Local Installation (Development)

Since this gem is not yet published to RubyGems, you can install it locally:

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

4. **Or use it directly without installing**:
   ```bash
   # Run directly from the repository
   ./bin/mcp-datetime-ruby
   
   # Or with bundle exec
   bundle exec ruby bin/mcp-datetime-ruby
   ```

### Standard Installation (Once Published)

Add this line to your application's Gemfile:

```ruby
gem 'mcp-datetime-ruby'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install mcp-datetime-ruby
```

## Uninstall

### Uninstalling the Gem

If you installed the gem (either locally built or from RubyGems):

```bash
# Uninstall the gem
gem uninstall mcp-datetime-ruby
```

If you have multiple versions installed, you'll be prompted to select which version to uninstall, or you can uninstall all versions:

```bash
# Uninstall all versions
gem uninstall mcp-datetime-ruby --all
```

### Removing from Cursor Configuration

If you've added the server to your Cursor configuration, remove the entry from `~/.cursor/mcp.json`:

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

### Cleaning Up Local Development

If you cloned the repository for development:

1. **Remove the cloned repository**:
   ```bash
   rm -rf /path/to/mcp-datetime-ruby
   ```

2. **Remove any locally built gem files**:
   ```bash
   rm mcp-datetime-ruby-*.gem
   ```

## Usage

### As an MCP Server

The gem provides an executable that can be used as an MCP server:

```bash
# If installed as a gem
mcp-datetime-ruby

# If running from the repository
./bin/mcp-datetime-ruby
```

### In Cursor

To add mcp-datetime-ruby to your MCP servers configuration:

1. **Locate or create the MCP configuration file**:
   - The configuration file is located at `~/.cursor/mcp.json`
   - If the file doesn't exist, create it

2. **Add the datetime server configuration**:

   If you installed the gem and have `~/bin` in your PATH:
   ```json
   {
     "mcpServers": {
       "datetime": {
         "command": "mcp-datetime-ruby"
       }
     }
   }
   ```

   If you need to use the full path (check with `which mcp-datetime-ruby`):
   ```json
   {
     "mcpServers": {
       "datetime": {
         "command": "/Users/yourusername/bin/mcp-datetime-ruby"
       }
     }
   }
   ```

   Or if using the repository directly without installation:
   ```json
   {
     "mcpServers": {
       "datetime": {
         "command": "/path/to/mcp-datetime-ruby/bin/mcp-datetime-ruby"
       }
     }
   }
   ```

3. **If you have existing MCP servers**, add the datetime server to the existing configuration:
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

4. **Restart Cursor** for the changes to take effect

5. **Verify the server is working**:
   - In Cursor, you should now have access to the datetime tools
   - Try asking the AI to "get the current time" or "what's today's date"

### Available Tools

The server provides two tools:

#### `get_current_datetime`

Get the current date and time in various formats.

Parameters:
- `format` (optional): One of `iso`, `human`, `date_only`, `time_only`, `unix`
- `timezone` (optional): IANA timezone name (e.g., "America/New_York", "Europe/London")

#### `get_date_info`

Get detailed information about the current date including:
- Date components (year, month, day)
- Weekday information
- Week/quarter of year
- Leap year status
- Days in month

## Testing

The gem includes comprehensive tests using Minitest. To run the tests:

```bash
# Run unit tests only (default)
bundle exec rake test

# Run integration tests only
bundle exec rake integration

# Run all tests (unit + integration)
bundle exec rake test_all

# Run tests with verbose output
bundle exec rake test TESTOPTS="--verbose"
```

The test suite includes:
- Unit tests for all MCP protocol methods
- Tests for each datetime format
- Error handling tests
- Integration tests for full server communication (in separate task)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wteuber/mcp-datetime-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). 