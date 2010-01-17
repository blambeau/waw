module Waw
  module Validation
    module ArrayValidations
      class ArrayValidator < Validator
        
        # Creates a validator instance with a delegator
        def initialize(subvalidator)
          @subvalidator = subvalidator
        end
        
        # Validation method
        def validate(*values)
          values.all?{|val| Array===val and subvalidator.validate(*val)}
        end
        
        # Convert and validate method
        def convert_and_validate(*values)
          my_converted = []
          values.each do |val|
            return [false, values] unless ::Array===val
            ok, converted = @subvalidator.convert_and_validate(*val)
            return [false, values] unless ok
            my_converted << converted.compact
          end
          [true, my_converted]
        end
        
      end
      module Methods
        # Checks that all values of the array are validated by a subvalidator
        def [](subvalidator)
          ArrayValidator.new(Waw::Validation.to_validator(subvalidator))
        end
      end
      extend Methods
    end # module ArrayValidations
  end # module Validation
end # module Waw
