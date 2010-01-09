module Waw
  module Validation
    class MissingValidator < Validator
    
      # Calls the block installed at initialization time    
      def validate(*values)
        values.all?{|value| Waw::Validation.is_missing?(value)}
      end
      alias :=== :validate
    
      # Converts and validate
      def convert_and_validate(*values)
        validate(*values) ? [true, values.collect{|v| nil}] : [false, values]
      end
    
    end # class MissingValidator
  end # module Validation
end # module Waw
