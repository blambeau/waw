module Waw
  module Validation
    # Validation linked to the length of the string
    module SizeValidations
      module Methods
        
        # Checks that it has a size
        def has_size?(val) val.respond_to?(:size) end
        
        # Builds a validator that verifies that the length is greater than
        # a specified value
        def >(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| has_size?(val) and (val.size > value)} }}
        end
    
        # Builds a validator that verifies that the length is greater-or-equal to
        # a specified value
        def >=(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| has_size?(val) and (val.size >= value)} }}
        end
    
        # Builds a validator that verifies that the length is less than
        # a specified value
        def <(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| has_size?(val) and (val.size < value)} }}
        end
    
        # Builds a validator that verifies that the length is less-or-equal to
        # a specified value
        def <=(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| has_size?(val) and (val.size <= value)} }}
        end
    
        # Builds a validator that verifies that the length is equal to a
        # specified value
        def ==(value)
          Validator.new {|*vals| Validation.argument_safe{ vals.all?{|val| has_size?(val) and (val.size == value)} }}
        end
        
      end
      extend Methods
    end # module SizeValidations
  end # module Validation
end # module Waw
