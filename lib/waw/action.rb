module Waw
  class ActionController < Waw::Controller
    # 
    # A Web action
    # 
    class Action
    
      # The action name
      attr_reader :name
    
      # Creates an action instance
      def initialize(name, signature, method)
        @name, @signature, @method = name, signature, method
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