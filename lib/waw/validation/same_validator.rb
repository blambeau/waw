module Waw
  module Validation
    # Checks that arguments are all non missing and equal
    class SameValidator < Validator
    
      def validate(*values)
        any_missing?(values) ? false : values.uniq.size==1
      end
    
      def convert_and_validate(*values)
        [validate(*values), values]
      end
    
    end # class IntegerValidator
  end # module Validation
end # module Waw
