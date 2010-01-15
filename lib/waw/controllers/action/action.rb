module Waw
  class ActionController < Waw::Controller
    # 
    # A Web action
    # 
    class Action
    
      # The action name
      attr_reader :name
    
      # Creates an action instance
      def initialize(name, signature, routing, method)
        @name, @signature, @routing, @method = name, signature, routing, method
      end
      
      # Public identifier of the action
      def public_id
        name
      end
      
      # Returns the underlying action routing 
      def routing
        @routing ||= ::Waw::Routing::ActionRouting.new
      end
    
      # Executes the action
      def execute(controller, params)
        ok, values = @signature.apply(params)
        if ok
          # validation is ok, merge params and continue
          [:success, @method.bind(controller).call(params.merge!(values))]
        else
          # validation is ko
          [:validation_ko, values]
        end
      end
    
    end # class Action
  end # class ActionController
end # module Waw