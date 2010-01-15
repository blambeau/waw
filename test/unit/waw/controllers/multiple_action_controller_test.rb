require 'waw'
require 'test/unit'
module Waw
  module Controllers
    class MultipleActionControllerTest < Test::Unit::TestCase
      class A < ::Waw::ActionController
        signature {}
        def action_1(params)
          "A.action_1"
        end
        signature {}
        def action_2(params)
          "A.action_2"
        end
      end
      class B < ::Waw::ActionController
        signature {}
        def action_1(params)
          "B.action_1"
        end
        signature {}
        def action_3(params)
          "B.action_3"
        end
      end
      
      def test_controllers
        assert [A, B].all?{|c| ::Waw::ActionController.controllers.include?(c)}
        assert A.controllers.object_id==::Waw::ActionController.controllers.object_id
        assert B.controllers.object_id==::Waw::ActionController.controllers.object_id
        assert A.controllers.object_id==B.controllers.object_id
      end
      
      def test_actions
        assert_equal 2, A.actions.size
        assert_equal 2, B.actions.size
        assert_equal [:action_1, :action_2], A.actions.keys.sort{|k1,k2| k1.to_s <=> k2.to_s}
        assert_equal [:action_1, :action_3], B.actions.keys.sort{|k1,k2| k1.to_s <=> k2.to_s}
        assert A.actions.object_id != B.actions.object_id
      end
      
      def test_has_action?
        assert A.has_action?(:action_1)
        assert A.has_action?(:action_2)
        assert !A.has_action?(:action_3)
        assert B.has_action?(:action_1)
        assert !B.has_action?(:action_2)
        assert B.has_action?(:action_3)
      end
      
      def test_find_action
        assert ::Waw::ActionController::Action===A.find_action(:action_1)
        assert ::Waw::ActionController::Action===A.find_action(:action_2)
        assert_nil A.find_action(:action_3)
        assert ::Waw::ActionController::Action===B.find_action(:action_1)
        assert ::Waw::ActionController::Action===B.find_action(:action_3)
        assert_nil B.find_action(:action_2)
      end
      
      def test_find_action_on_instance
        assert ::Waw::ActionController::Action===A.instance.find_action(:action_1)
        assert ::Waw::ActionController::Action===A.instance.find_action(:action_2)
        assert_nil A.instance.find_action(:action_3)
        assert ::Waw::ActionController::Action===B.instance.find_action(:action_1)
        assert ::Waw::ActionController::Action===B.instance.find_action(:action_3)
        assert_nil B.instance.find_action(:action_2)
      end
      
      def test_action_execution
        assert_equal [:success, "A.action_1"], A[:action_1].execute
        assert_equal [:success, "A.action_2"], A[:action_2].execute
        assert_equal [:success, "B.action_1"], B[:action_1].execute
        assert_equal [:success, "B.action_3"], B[:action_3].execute
      end
      
    end
  end
end