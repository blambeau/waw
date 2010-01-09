module Waw
  module Validation

    # Provides utilities for validating arrays
    class ArrayValidations
    
      # Checks that all values of the array are validated by a subvalidator
      def [](subvalidator)
        Validator.new{|val| (::Array===val) && val.all?{|v| subvalidator===v}}
      end
    
    end # class ArrayValidations
  end # module Validation
end # module Waw
