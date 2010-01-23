require 'json'
module Waw
  module WSpec
    class Scenario
      
      # The scenario name
      attr_reader :name
      
      # The browser instance underlying this scenario
      attr_reader :browser
      
      # Number of assertions done
      attr_reader :assertion_count
      
      # Creates a scenario instance
      def initialize(name, &block)
        @name = name
        @browser = Browser.new
        @block = block
        @assertion_count = 0
        
        @because = []
      end
      
      # Adds an assertion
      def add_assertion
        @assertion_count += 1
      end
      
      # Run the test scenario
      def run
        DSL.new(self).__execute(&@block)
      end
      
    end # class Scenario
  end # module WSpec
end # module Waw
