module Waw
  module Validation
    class MissingValidator < Validator
    
      # Calls the block installed at initialization time    
      def validate(*values)
        values.all?{|value| is_missing?(value)}
      end
    
      # Converts and validate
      def convert_and_validate(*values)
        validate(*values) ? [true, missings_to_nil(values)] : [false, values]
      end
    
    end # class MissingValidator
  end # module Validation
end # module Waw
