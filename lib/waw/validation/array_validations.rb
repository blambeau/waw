module Waw
  module Validation
    module ArrayValidations
      module Methods
        # Checks that all values of the array are validated by a subvalidator
        def [](subvalidator)
          Validator.new{|val| (::Array===val) && val.all?{|v| subvalidator===v}}
        end
      end
      extend Methods
    end # module ArrayValidations
  end # module Validation
end # module Waw
