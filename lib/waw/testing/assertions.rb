require 'test/unit/assertions'
module Waw
  module Testing
    module Assertions
      include ::Test::Unit::Assertions
      
      # Checks if the last request was answered by a 404 not found
      def is404
        browser.is404
      end
      
      # Asserts that the invocation of a service leads to a given result
      def assert_json_service_result(json_response, result, msg=nil)
        assert_equal json_response[0], result, msg
      end
      
      # Asserts that the invocation of a service is a success
      def assert_success_json_service(json_response, msg=nil)
        assert_json_service_result(json_response, "success", msg)
      end
      
      # Asserts that a given service matches something
      def assert_json_service_result_matches(json_response, what, msg=nil)
        assert Waw::Routing.matches?(json_response, what), msg
      end
      
    end # module Assertions
  end # module Testing
end # module Waw
