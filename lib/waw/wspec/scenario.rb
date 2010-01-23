require 'json'
module Waw
  module WSpec
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
      
      # Simply returns opts
      def with(opts)
        opts
      end
      
      # I reach a given page
      def i_reach(which_page)
        assert_200 which_page, @because.last + " (cannot actually reach #{which_page})"
      end
      
      # I reach a given page
      def i_dont_reach(which_page)
        assert_not_200 which_page, @because.last + " (may actually reach #{which_page})"
      end
      
      # I see something on the page
      def i_see(what)
        assert_i_see what, @because.last + " (don't see #{what})"
      end
      
      # Asserts that I see a particular tag
      def i_see_tag(tag, opts = {})
        assert_has_tag tag, opts, @because.last + " (don't see tag <#{tag} #{opts.inspect})"
      end
      
      # Asserts that I can invoke a given action
      def i_can_invoke(action, opts = {})
        action = action.url if ::Waw::ActionController::Action===action
        invoke_json_service(action, opts)
      end
      
    end # class Scenario
  end # module WSpec
end # module Waw
