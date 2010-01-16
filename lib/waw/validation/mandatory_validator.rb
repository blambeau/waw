module Waw
  module Validation
    class MandatoryValidator < Validator
    
      # Calls the block installed at initialization time    
      def validate(*values)
        no_missing?(values)
      end
    
      # Converts and validate
      def convert_and_validate(*values)
        validate(*values) ? [true, values] : [false, values]
      end
    
    end # class MissingValidator
  end # module Validation
end # module Waw
