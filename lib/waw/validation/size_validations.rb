module Waw
  module Validation
    # Validation linked to the length of the string
    class SizeValidations
    
      # Builds a validator that verifies that the length is greater than
      # a specified value
      def >(value)
        Validator.new {|val| val.size > value}
      end
    
      # Builds a validator that verifies that the length is greater-or-equal to
      # a specified value
      def >=(value)
        Validator.new {|val| val.size >= value}
      end
    
      # Builds a validator that verifies that the length is less than
      # a specified value
      def <(value)
        Validator.new {|val| val.size < value}
      end
    
      # Builds a validator that verifies that the length is less-or-equal to
      # a specified value
      def <=(value)
        Validator.new {|val| val.size <= value}
      end
    
      # Builds a validator that verifies that the length is equal to a
      # specified value
      def ==(value)
        Validator.new {|val| val.size == value}
      end
    
    end # class SizeValidations
  end # module Validation
end # module Waw
