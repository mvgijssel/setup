# frozen_string_literal: true

require 'bundler'
require 'active_support'
require 'active_support/core_ext'

require 'rspec/server_helpers/version'
require 'rspec/server_helpers/result'
require 'rspec/server_helpers/helpers'

module RSpec
  module ServerHelpers
    def self.reactor
      @reactor ||= Async::Reactor.new
    end
  end
end

# To make sure processes started with Async::Process within the reactor are stopped!
# For some reason the reactor.stop method needs to be called twice, which will happen
# when force quitting RSpec.
Signal.trap('INT') do
  RSpec::ServerHelpers.reactor.stop
  RSpec::Core::Runner.handle_interrupt
end

RSpec.configure do |config|
  config.include RSpec::ServerHelpers::Helpers

  config.around(:each) do |example|
    RSpec::ServerHelpers.reactor.async do
      aggregate_failures do
        example.run
      end
    end
    RSpec::ServerHelpers.reactor.run
    RSpec::ServerHelpers.reactor.stop
  end
end
