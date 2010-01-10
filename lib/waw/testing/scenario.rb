require 'json'
module Waw
  module Testing
    class Scenario
      include Assertions
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
      
      # Sets the current location
      def location(location)
        @browser.location = location
      end
      
      # Follow some tag (typically a <a href="..."> or a <form action="...">)
      def follow(tag, attributes)
        assert_not_nil(found = has_tag?(tag, attributes), "tag #{tag}, #{attributes.inspect} can be found for follow")
        case tag
          when 'a', :a
            browser.click_href(found[:href])
          else
            raise ArgumentError, "Unexpected tag type #{tag} for follow"
        end
      end
      
      # Adds an assertion
      def add_assertion
        @assertion_count += 1
      end
      
      # Run the test scenario
      def run
        self.instance_eval &@block
      end
      
      # Execute the action routing of a given result
      def execute_action_routing(service, result)
        app = Waw.find_rack_app(service) {|app| Waw::ActionController===app}
        assert_not_nil app, "Service #{service} has been found"
        assert Waw::ActionController===app, "Invoked service #{service} by an action controller"
        action = app.find_action(service)
        assert_not_nil action, "If service is found, an action is matching"
        action.routing.apply_on_browser(result, browser) if action.routing
        result
      end
      
      # Invokes a server json service
      def invoke_json_service(service, data)
        case res = browser.server_invoke(service, data)
          when Net::HTTPSuccess
            execute_action_routing(service, JSON.parse(res.body))
          when Net::HTTPNotFound
            assert false, "JSON service #{service} can be found"
        end
      end
      
    end # class Scenario
  end # module Testing
end # module Waw
