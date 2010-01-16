module Waw
  module Validation
    module ComparisonValidations
      module Methods
        
        # Builds a validator that verifies that the length is greater than
        # a specified value
        def >(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| val.respond_to?(:>) and val > value} }}
        end
    
        # Builds a validator that verifies that the length is greater-or-equal to
        # a specified value
        def >=(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| val.respond_to?(:>=) and val >= value} }}
        end
    
        # Builds a validator that verifies that the length is less than
        # a specified value
        def <(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| val.respond_to?(:<) and val < value} }}
        end
    
        # Builds a validator that verifies that the length is less-or-equal to
        # a specified value
        def <=(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| val.respond_to?(:<=) and val <= value} }}
        end
    
        # Builds a validator that verifies that the length is equal to a
        # specified value
        def ==(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| val.respond_to?(:==) and val == value} }}
        end
        
        # Same as Waw::Validation.isin
        def in(*values)
          Waw::Validation.isin(*values)
        end
        
      end
      extend Methods
    end # module ComparisonValidations
  end # module Validation
end # module Waw
