require 'waw'
require 'waw/wspec'

if RUBY_VERSION >= "1.9"
  # These classes don't seem to exist in some Ruby 1.9 installations
  module Test
    module Unit
      class AssertionFailedError < StandardError
      end
    end
  end
else
  # These classes don't seem to exist in some Ruby 1.8 installations
  module MiniTest
    class Assertion < StandardError
    end
  end
end

# The autoloaded scenarios
$scenarios = []
def scenario(name, &block)
  $scenarios << Waw::WSpec::Scenario.new(name, &block)
end

# We run the whole suite at end
at_exit {
  begin
    puts "Running wspec test suite now"
  
    # Load waw through rack in a different thread
    puts "Loading waw application and web server"
    t = Thread.new(Waw.kernel) do |app|
      begin
        server = Rack::Handler::Mongrel
      rescue LoadError => e
        server = Rack::Handler::WEBrick
      end
      options = {:Port => Waw.config.web_port, :Host => "0.0.0.0", :AccessLog => []}
      server.run app, options
    end
  
    # Wait until the server is loaded
    try, ok = 0, false
    begin
      puts "Attempting to reach the web server..."
      Net::HTTP.get(URI.parse(Waw.config.web_base))
      ok = true
    rescue Errno::ECONNREFUSED => ex
      sleep 0.1
    end until (ok or (try += 1)>10)
  
    # Create the suite and run it
    if ok
      s = ::Waw::WSpec::Suite.new($scenarios)
      t1 = Time.now
      s.run
      t2 = Time.now
      puts "\nFinished in #{Time.now - t1} seconds.\n"
      puts "#{s.scenario_count} scenarios, #{s.assertion_count} assertions, #{s.failure_count} failures, #{s.error_count} errors"
    else
      raise WawError, "Unable to reach the local web server... sorry!"
    end

  ensure   
    # Kill the web server thread
    t.kill if t
  end
}