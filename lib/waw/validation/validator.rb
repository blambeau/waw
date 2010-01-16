module Waw
  module Validation
    #
    # A validator reusable class.
    #
    class Validator
      include ::Waw::Validation::Helpers
      
      # Creates a validator instance that takes a block as validation code
      def initialize(&block)
        @block = block
      end
      
      # Calls the block installed at initialization time    
      def validate(*values)
        raise "Missing validation block on #{self}" unless @block
        @block.call(*values)
      end
      def ===(*args)
        validate(*args)
      end
    
      # Converts and validate
      def convert_and_validate(*values)
        validate(*values) ? [true, values] : [false, values]
      end
      def =~(*args)
        convert_and_validate(*args)
      end
    
      # Negates this validator
      def not
        NotValidator.new(self)
      end
    
      # Creates a validator by disjunction
      def |(validator)
        OrValidator.new(self, Waw::Validation.to_validator(validator))
      end
    
      # Creates a validator by conjunction
      def &(validator)
        AndValidator.new(self, Waw::Validation.to_validator(validator))
      end
    
    end # class Validator
  end # module Validation
end # module Waw
