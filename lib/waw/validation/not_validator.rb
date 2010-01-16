module Waw
  module Validation
    class NotValidator < Validator
    
      def initialize(negated)
        @negated = negated
      end
    
      def validate(*values)
        not(@negated.validate(*values))
      end
    
      def convert_and_validate(*values)
        ok, converted = @negated.convert_and_validate(*values)
        ok ? [false, values] : [true, converted]
      end
    
    end # class NotValidator
  end # module Validation
end # module Waw
