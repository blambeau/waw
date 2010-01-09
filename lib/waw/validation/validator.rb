module Waw
  module Validation
    #
    # A validator reusable class.
    #
    class Validator
    
      # Creates a validator instance that takes a block as validation code
      def initialize(&block)
        @block = block
      end

      # Calls the block installed at initialization time    
      def validate(*values)
        raise "Missing validation block on #{self}" unless @block
        @block.call(*values)
      end
      alias :=== :validate
    
      # Converts and validate
      def convert_and_validate(*values)
        validate(*values) ? [true, values] : [false, values]
      end
    
      # Negates this validator
      def not
        NotValidator.new(self)
      end
    
      # Creates a validator by disjunction
      def |(validator)
        OrValidator.new(self, validator)
      end
    
      # Creates a validator by conjunction
      def &(validator)
        AndValidator.new(self, validator)
      end
    
    end # class Validator
  end # module Validation
end # module Waw
