require 'test/unit'
require 'waw'
module Waw
  class ActionControllerTest < Test::Unit::TestCase
    
    class MyMailController < Waw::ActionController
      
      def this_is_possible
      end
      
      signature {
        validation :mail, mandatory, :missing_email
        validation :mail, mail, :invalid_email
      }
      def subscribe(params)
        this_is_possible
        :ok
      end
      
      signature {
        validation :age, integer & (is>18), :bad_age
      }
      def say_hello_to_adult(params)
        params[:age]
      end
      
      def not_an_action
      end
      
    end
    
    def controller
      MyMailController.instance
    end
    
    def test_singleton_pattern
      assert_equal false, MyMailController.respond_to?(:new)
      assert_equal true, MyMailController.respond_to?(:instance)
    end
    
    def test_installed_method_on_instance
      assert MyMailController.instance.respond_to?(:subscribe)
    end
    
    def test_installed_method_on_class
      assert MyMailController.respond_to?(:subscribe)
      assert ::Waw::ActionController::Action===MyMailController.subscribe
    end
    
    def test_js_generation_has_seen_new_controller
      assert ::Waw::ActionController.controllers.include?(MyMailController)
    end
    
    def test_controller_installation
      assert controller.respond_to?(:subscribe)
      assert controller.respond_to?(:not_an_action)
      assert_equal false, controller.respond_to?(:action_not_an_action)
      assert controller.has_action?(:subscribe)
      assert controller.has_action?("/services/subscribe")
    end
    
    def test_controller_subscribe
      assert_equal [:success, :ok], controller.subscribe(:mail => "blambeau@gmail.com")
      assert_equal [:"validation-ko", [:invalid_email]], controller.subscribe(:mail => "blambeau_gmail.com")
      assert_equal [:"validation-ko", [:missing_email, :invalid_email]], controller.subscribe(:mail => nil)
    end
    
    def test_controller_say_hello_to_adult
      assert_equal [:success, 20], controller.say_hello_to_adult(:age => 20)
      assert_equal [:success, 20], controller.say_hello_to_adult(:age => "20")
      assert_equal [:success, 20], controller.say_hello_to_adult(:age => " 20 ")
      assert_equal [:"validation-ko", [:bad_age]], controller.say_hello_to_adult(:age => "18")
    end
    
  end
end