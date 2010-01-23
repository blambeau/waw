require 'test/unit/assertions'
module Waw
  module WSpec
    module Assertions
      include ::Test::Unit::Assertions
      
      #################################################################### Assertions about HTTP and browser
      
      # Asserts that going to a given location leads to a 404 Not Found error
      def assert_404(location, msg="Location #{location} is a 404")
        go location
        assert browser.is404?, msg
      end
      alias :assert_is_404 :assert_404
      alias :assert_is404 :assert_404
      
      # Asserts that going to a given location does not lead to a 404
      # Not found error
      def assert_not_404(location, msg="Location #{location} is not a 404")
        go location
        assert !browser.is404?, msg
      end
      alias :assert_is_not_404 :assert_not_404
      
      # Asserts that going to a given location leads to a 200 OK response
      def assert_200(location, msg="Location #{location} is a 200 OK")
        go location
        assert browser.is200?, msg
      end
      alias :assert_is_200 :assert_200
      alias :assert_is200 :assert_200
      
      # Asserts that going to a given location does not lead to a 200 response
      def assert_not_200(location, msg="Location #{location} is not a 200 OK")
        go location
        assert !browser.is200?, msg
      end
      alias :assert_is_not_200 :assert_not_200
      
      #################################################################### Assertions about HTML contents
      
      # Asserts that I see something
      def assert_i_see(what, msg = "User sees |#{what}| on the current page")
        assert i_see?(what), msg
      end
      
      # Asserts that I dont see something
      def assert_i_dont_see(what, msg = "User does not see |#{what}| on the current page")
        assert !i_see?(what), msg
      end
      
      # Asserts that a tag can be found
      def assert_has_tag(name, opts, msg="Tag <#{name} #{opts.inspect}> can be found")
        assert has_tag?(name, opts), msg
      end
      
      #################################################################### Assertions about service invocations
      
      # Asserts that the invocation of a service leads to a given result
      def assert_json_service_result(json_response, result, msg="")
        assert_equal json_response[0], result, (msg + "\nresult was #{result.inspect}")
      end
      
      # Asserts that the invocation of a service is a success
      def assert_success_json_service(json_response, msg="")
        assert_json_service_result(json_response, "success", msg)
      end
      
      # Asserts that a given service matches something
      def assert_json_service_result_matches(json_response, what, msg="")
        assert Waw::Routing.matches?(what, json_response), msg + "\n(#{what} against #{json_response.inspect})"
      end
      
      # Asserts that a server-side service invocation leads to a given action
      # result
      def assert_service_invoke(msg, opts)
        raise ArgumentError, "assert_form_service_invoke expects :service, :arguments, :result keys, (#{caller[0]})\n"\
                             "#{opts.keys.inspect} received."\
          unless [:service, :arguments, :result].all?{|k| opts.has_key?(k)}
        result = service(opts[:service], opts[:arguments])
        assert_not_nil result, "assert_service_invoke block leads to a service result (#{caller[0]})"
        assert Waw::Routing.matches?(opts[:result], result), "#{msg}\n (#{opts[:result]} expected, found #{result.inspect})"
      end
      
      # Asserts that a form for a given service exists and that invoking this services 
      # matches a given action result
      def assert_form_service_invoke(msg, opts)
        raise ArgumentError, "assert_form_service_invoke expects :service, :arguments, :result keys, (#{caller[0]})\n"\
                             "#{opts.keys.inspect} received."\
          unless [:service, :arguments, :result].all?{|k| opts.has_key?(k)}
        if opts[:check_form].nil? or opts[:check_form]
          app = Waw.find_rack_app(opts[:service]) {|app| ::Waw::ActionController===app}
          action_name = Waw::ActionController.extract_action_name(opts[:service])
          action = app.find_action(action_name)
          assert_has_tag "form", :id => action.id
        end
        assert_service_invoke msg, opts
      end
      
    end # module Assertions
  end # module WSpec
end # module Waw
