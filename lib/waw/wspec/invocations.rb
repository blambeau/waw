module Waw
  module WSpec
    module Invocations

      #################################################################### GET invocations
      
      # Sets the current location on the browser
      def location(location)
        @browser.location = location
      end
      alias :go :location
      
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
      
      #################################################################### Services invocations
      
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
            result = execute_action_routing(service, JSON.parse(res.body))
            result.extend(Waw::Routing::Methods)
            result
          when Net::HTTPNotFound
            assert false, "JSON service #{service} can be found"
        end
      end
      alias :service :invoke_json_service
      
    end # module Invocations
  end # module WSpec
end # module Waw