module Waw
  module Validation
    # Validation linked to the length of the string
    module SizeValidations
      module Methods
        # Builds a validator that verifies that the length is greater than
        # a specified value
        def >(value)
          Validator.new {|val| val and val.respond_to?(:size) and(val.size > value)}
        end
    
        # Builds a validator that verifies that the length is greater-or-equal to
        # a specified value
        def >=(value)
          Validator.new {|val| val and val.respond_to?(:size) and(val.size >= value)}
        end
    
        # Builds a validator that verifies that the length is less than
        # a specified value
        def <(value)
          Validator.new {|val| val and val.respond_to?(:size) and(val.size < value)}
        end
    
        # Builds a validator that verifies that the length is less-or-equal to
        # a specified value
        def <=(value)
          Validator.new {|val| val and val.respond_to?(:size) and(val.size <= value)}
        end
    
        # Builds a validator that verifies that the length is equal to a
        # specified value
        def ==(value)
          Validator.new {|val| val and val.respond_to?(:size) and(val.size == value)}
        end
      end
      extend Methods
    end # module SizeValidations
  end # module Validation
end # module Waw
