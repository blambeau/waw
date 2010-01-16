module Waw
  module Validation
    class DefaultValidator < Validator
    
      # Creates a validator instance
      def initialize(*args)
        error("Validator default expects one argument (only): default(19) for example", caller) unless args.size==1
        @default_value = args[0]
      end
    
      # Always returns true
      def validate(*values)
        all_missing?(values)
      end
    
      # Converts missing values by the default one
      def convert_and_validate(*values)
        validate(*values) ? [true, values.collect{|v| @default_value}] : [false, values]
      end
    
    end # class DefaultValidator
  end # module Validation
end # module Waw
