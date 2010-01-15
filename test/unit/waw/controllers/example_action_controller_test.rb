require 'waw'
require 'test/unit'
module Waw
  module Controllers
    class ExampleActionControllerTest < Test::Unit::TestCase
      
      class A < ::Waw::ActionController
        
        signature {}
        def say_hello(params)
          :ok
        end
        
      end
      
      def test_show_what_happened
        assert A.respond_to?(:say_hello)
        assert ::Waw::ActionController::Action === A.say_hello
        assert_equal [:success, :ok], A.instance.say_hello({})
      end
      
    end
  end
end