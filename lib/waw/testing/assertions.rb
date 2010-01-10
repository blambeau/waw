require 'test/unit/assertions'
module Waw
  module Testing
    module Assertions
      include ::Test::Unit::Assertions
      
      #################################################################### Assertions about HTTP and browser
      
      # Asserts that going to a given location does not lead to a 404
      # Not found error
      def assert_not_404(location, msg="Location #{location} is not a 404")
        go location
        assert !browser.is404?, msg
      end
      
      #################################################################### Assertions about HTML contents
      
      # Asserts that I see something
      def assert_i_see(what, msg = "User sees |#{what}| on the current page")
        assert i_see?(what), msg
      end
      
      # Asserts that a tag can be found
      def assert_has_tag(name, opts, msg="Tag <#{name} #{opts.inspect}> can be found")
        assert has_tag?(name, opts), msg
      end
      
      #################################################################### Assertions about service invocations
      
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
      
      def assert_service_invoke(match, msg="")
        result = yield
        assert_not_nil result, "assert_service_invoke block leads to a service result (#{caller[0]})"
        assert Waw::Routing.matches?(match, result), "#{msg}\n (#{match} expected, found #{result.inspect})"
      end
      
    end # module Assertions
  end # module Testing
end # module Waw
