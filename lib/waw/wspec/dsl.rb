module Waw
  module WSpec
    # 
    # Provides the DSL of the .wspec scenario language.
    #
    class DSL
      include Assertions
      include Invocations
      include HTMLAnalysis
    
      # Creates a DSL instance for a given scenario
      def initialize(scenario)
        @scenario = scenario
      end
      
      #################################################################### Semi-private utilities
      
      # Executes some code
      def __execute(&block)
        self.instance_eval(&block)
      end
    
      # A stack of execution context  
      def __stack
        @stack ||= [["Outside because clauses", Browser.new]]
      end
      
      # Returns the last because clause
      def __last_because
        @stack.last[0]
      end
      
      # Adds an assertion
      def add_assertion
        @scenario.add_assertion
      end
      
      #################################################################### About browser
      
      # Returns the current browser instance
      def browser
        @stack.last[1]
      end
      
      # Returns current browser contents (used by HTMLAnalysis)
      def browser_contents
        browser.contents
      end
      alias :contents :browser_contents
      
      # Goes to a given location and returns the HTTPResponse object
      def go(location)
        browser.location = location
        browser.response
      end
      
      #################################################################### About scenario execution
      
      # Because some condition holds...
      def because(msg="Unknown cause", &block)
        raise ArgumentError, "WSpec because expects a block" unless block
        __stack.push([msg, browser.dup])
        yield(browser)
        __stack.pop
      end
      
      #################################################################### About reaching pages
      
      # Asserts that a page can be reached, leading to a Net::HTTPSuccess result
      def i_reach(which_page)
        result = go(which_page)
        assert Net::HTTPSuccess===result, __last_because + " (cannot actually reach #{which_page}: #{result})"
      end
      
      # Asserts that a page cannot be reached, leading to a Net::HTTPNotFound or a Net::HTTPForbidden (403)
      # result
      def i_dont_reach(which_page)
        result = go(which_page)
        assert (Net::HTTPNotFound===result or Net::HTTPForbidden===result), __last_because + " (can reach #{which_page}: #{result})"
      end
      
      # Asserts that a page may not be reached, leading to a Net::HTTPForbidden (403) result.
      def i_may_not_reach(which_page)
        result = go(which_page)
        assert Net::HTTPForbidden===result, __last_because + " (may actually reach #{which_page}: #{result})"
      end
      
      #################################################################### About seeing something on the page
      
      # Asserts that something can be seen on the current page
      def i_see(what)
        assert i_see?(what), __last_because + " (don't see #{what})"
      end
      
      # Asserts that I see a particular tag (see HTMLAnalysis.tag)
      def i_see_tag(name, opts = {})
        assert has_tag?(name, opts), __last_because + " (don't see tag <#{name} #{opts.inspect})"
      end
      
    end # class DSL
  end # module WSpec
end # module Waw