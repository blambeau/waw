module Waw
  module Validation
    class BooleanValidator < Validator
    
      def is_boolean?(value)
        (value==true) || (value==false)
      end
    
      def to_boolean(value)
        return value if validate(value)
        case value.to_s.strip
          when 'true'
            true
          when 'false'
            false
          else 
            nil
        end 
      end
    
      def validate(*values)
        values.all?{|val| is_boolean?(val)}
      end
    
      def convert_and_validate(*values)
        converted = values.collect{|v| to_boolean(v)}
        validate(*converted) ? [true, converted] : [false, values]
      end
    
    end # class BooleanValidator
  end # module Validation
end # module Waw
