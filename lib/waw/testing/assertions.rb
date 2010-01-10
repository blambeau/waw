require 'test/unit/assertions'
module Waw
  module Testing
    module Assertions
      include ::Test::Unit::Assertions
      
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
          when Net::HTTPNotFound
            assert false, "JSON service #{service} can be found"
        end
      end
      
      def service(*args)
        args
      end
      
      # Checks if the last request was answered by a 404 not found
      def is404
        browser.is404
      end
      
      # Asserts that the invocation of a service leads to a given result
      def assert_json_service_result(json_response, result, msg="")
        assert_equal json_response[0], result, (msg + "\nresult was result.inspect")
      end
      
      # Asserts that the invocation of a service is a success
      def assert_success_json_service(json_response, msg="")
        assert_json_service_result(json_response, "success", msg)
      end
      
      # Asserts that a given service matches something
      def assert_json_service_result_matches(json_response, what, msg="")
        assert Waw::Routing.matches?(what, json_response), msg + "\n(#{what} against #{json_response.inspect})"
      end
      
      def assert_server_invoke(match, msg="")
        service, data = yield
        case res = browser.server_invoke(service, data)
          when Net::HTTPSuccess
            result = execute_action_routing(service, JSON.parse(res.body))
            result.extend(Waw::Routing::Methods)
          when Net::HTTPNotFound
            assert false, "JSON service #{service} can be found"
        end
      end
      
    end # module Assertions
  end # module Testing
end # module Waw
