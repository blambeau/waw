module Waw
  module FullState
    class Variable
      include Waw::ScopeUtils
      
      # Creates a variable instance with a default value
      def initialize(name, default_value = nil, &block)
        raise ArgumentError, "Waw variables accept a default value or a block, but not both"\
          unless default_value.nil? or block.nil?
        @name, @default_value = name, (block ? block : default_value)
      end
      
      # Resets to the default value
      def reset
        session.unset(@name)
      end
      
      # Returns the current value of the variable
      def value(*args)
        if session.has_key?(@name)
          session.get(@name)
        elsif @default_value.is_a?(Proc)
          @default_value.call(*args)
        else
          @default_value
        end
      end
      
      # Sets the value of the variable
      def value=(val)
        session.set(@name, val)
      end
      
    end # class Variable
  end # module FullState
end # module Waw