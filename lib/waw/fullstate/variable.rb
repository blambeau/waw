module Waw
  module FullState
    class Variable
      
      # Creates a variable instance with a default value
      def initialize(name, default_value = nil, &block)
        raise ArgumentError, "Waw variables accept a default value or a block, but not both"\
          unless default_value.nil? or block.nil?
        @name, @default_value = name, (block ? block : default_value)
      end
      
      # Resets to the default value
      def reset
        Waw.session_unset(@name)
      end
      
      # Returns the current value of the variable
      def value(*args)
        if Waw.session_has_key?(@name)
          Waw.session_get(@name)
        elsif @default_value.is_a?(Proc)
          @default_value.call(*args)
        else
          @default_value
        end
      end
      
      # Sets the value of the variable
      def value=(val)
        Waw.session_set(@name, val)
      end
      
    end # class Variable
  end # module FullState
end # module Waw