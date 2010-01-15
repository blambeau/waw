module Waw
  class ActionController < Waw::Controller
    # 
    # A Web action, inside an ActionController.
    # 
    class Action
    
      # Action name
      attr_reader :name
      
      # Action signature (pre-conditions and validation)
      attr_reader :signature
      
      # Action routing
      attr_reader :routing
    
      # Creates an action instance
      def initialize(name, signature, routing, method)
        @name, @signature, @routing, @method = name, signature, routing, method
        @routing = ::Waw::Routing::ActionRouting.new unless @routing
      end
      
      # Public identifier of the action
      def public_id
        name
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