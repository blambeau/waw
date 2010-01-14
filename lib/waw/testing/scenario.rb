require 'json'
module Waw
  module Testing
    class Scenario
      include Assertions
      include Invocations
      include HTMLAnalysis
      
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
        self.instance_eval(&@block)
      end
      
      # Because some condition holds...
      def because(msg="Unknown cause", &block)
        if block
          @because.push(msg)
          block.call
          @because.pop
        else
          puts "Warning, no block given in because clause: #{msg}"
        end
      end
      
      # I reach a given page
      def i_reach(which_page)
        assert_200 which_page, @because.last
      end
      
      # I reach a given page
      def i_dont_reach(which_page)
        assert_not_200 which_page, @because.last
      end
      
      # I see something on the page
      def i_see(what)
        assert_i_see what, @because.last
      end
      
    end # class Scenario
  end # module Testing
end # module Waw
