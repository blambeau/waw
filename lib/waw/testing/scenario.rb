require 'json'
module Waw
  module Testing
    class Scenario
      include Assertions
      include Invocations
      include HTMLAnalysis
      
      # The browser instance underlying this scenario
      attr_reader :browser
      
      # Number of assertions done
      attr_reader :assertion_count
      
      # Creates a scenario instance
      def initialize(&block)
        @browser = Browser.new
        @block = block
        @assertion_count = 0
      end
      
      # Adds an assertion
      def add_assertion
        @assertion_count += 1
      end
      
      # Run the test scenario
      def run
        self.instance_eval(&@block)
      end
      
    end # class Scenario
  end # module Testing
end # module Waw
