# MCP DateTime Ruby

A Ruby implementation of an MCP (Model Context Protocol) server that provides datetime tools for AI assistants.

## Installation

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

## Usage

### As an MCP Server

The gem provides an executable that can be used as an MCP server:

```bash
mcp-datetime-ruby
```

### In Cursor

Add to your `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "datetime": {
      "command": "mcp-datetime-ruby"
    }
  }
}
```

Or if installed locally:

```json
{
  "mcpServers": {
    "datetime": {
      "command": "/path/to/mcp-datetime-ruby/bin/mcp-datetime-ruby"
    }
  }
}
```

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