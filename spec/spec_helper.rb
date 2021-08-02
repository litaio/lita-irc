# frozen_string_literal: true

# Generate code coverage metrics outside CI.
unless ENV["CI"]
  require "simplecov"
  SimpleCov.start { add_filter "/spec/" }
end
require "lita-irc"
require "lita/rspec"
