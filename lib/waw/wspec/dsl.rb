require 'test/unit/assertions'
module Waw
  module WSpec
    # 
    # Provides the DSL of the .wspec scenario language.
    #
    class DSL
      include ::Test::Unit::Assertions
      include HTMLAnalysis
    
      # Creates a DSL instance for a given scenario
      def initialize(scenario)
        @scenario = scenario
        @browser = Browser.new
      end
      
      #################################################################### Semi-private utilities
      
      # Executes some code
      def __execute(&block)
        self.instance_eval(&block)
      end
    
      # A stack of execution context  
      def __stack
        @stack ||= []
      end
      
      # Returns the last because clause
      def __last_because
        @stack.last
      end
      
      # Adds an assertion
      def add_assertion
        @scenario.add_assertion
      end
      
      #################################################################### About scoping
      
      # Delegates to waw ressources
      def method_missing(name, *args, &block)
        if args.empty? and Waw.resources and Waw.resources.has_resource?(name)
          Waw.resources[name]
        else
          super(name, *args, &block)
        end
      end
      
      #################################################################### About browser
      
      # Returns the current browser instance
      def browser
        @browser
      end
      
      # Returns current browser contents (used by HTMLAnalysis)
      def browser_contents
        browser.contents
      end
      alias :contents :browser_contents
      
      # Returns the URL of the index page (the web_base actually)
      # This method returns nil unless the Waw application has been loaded
      def index_page
        Waw.config && Waw.config.web_base
      end
      
      # Goes to a given location and returns the HTTPResponse object
      def go(location)
        browser.location = location
        browser.response
      end
      
      # Simply returns args
      def with(args = {})
        args
      end
      
      #################################################################### About scenario execution
      
      # Because some condition holds...
      def because(msg="Unknown cause", &block)
        raise ArgumentError, "WSpec because/therefore expects a block" unless block
        __stack.push(msg)
        yield(browser)
        __stack.pop
      end
      alias :therefore :because
      
      #################################################################### About reaching pages
      
      # Asserts that a page can be reached, leading to a Net::HTTPSuccess result
      def i_reach(which_page)
        result = go(which_page)
        assert Net::HTTPSuccess===result, __last_because + " (cannot actually reach #{which_page}: #{result})"
      end
      
      # Asserts that a page could be reached (requesting headers leads to a Net::HTTPSucess result)
      def i_could_reach(which_page)
        return if which_page.nil? or '#'==which_page 
        case which_page
          when Tag
            i_could_reach(which_page[:href])
          when Array
            which_page.each{|link| i_could_reach(link)}
          when String
            result = browser.headers_fetch(which_page)
            assert Net::HTTPSuccess===result, __last_because + " (could not reach #{which_page}: #{result})"
          else
            raise ArgumentError, "Unable to use #{which_page} for i_could_reach"
        end
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
      
      # Asserts that something is not present on the current page
      def i_dont_see(what)
        assert !i_see?(what), __last_because + " (actually see #{what})"
      end
      
      # Asserts that I see a particular tag (see HTMLAnalysis.tag)
      def i_see_tag(name, opts = nil)
        assert has_tag?(name, opts), __last_because + " (don't see tag <#{name} #{opts.inspect})"
      end
      
      # Asserts that I see a particular link (see HTMLAnalysis.link)
      def i_see_link(opts = nil)
        assert has_link?(opts), __last_because + " (dont see link <a #{opts.inspect})"
      end
      
      #################################################################### About forms and action
      
      # Submits some form with optional arguments
      def i_submit(form, args = {})
        assert_not_nil form, __last_because + "(form has not been found)"
        i_invoke(form[:action], args)
      end
      
      # Directly invoke an action or service server side, bypassing 
      # form lookup and so on.
      def i_invoke(action, args = {})
        result = case action
          when String
            browser.invoke_service(action, args)
          when ::Waw::ActionController::Action
            browser.invoke_action(action, args)
          else
            raise ArgumentError, "Unable to apply i_invoke on #{action.inspect}, unable to catch the associated action"
        end
        assert Net::HTTPSuccess===result, __last_because + " (invoking #{action.inspect} led to: #{result})"
        result
      end
      
    end # class DSL
  end # module WSpec
end # module Waw