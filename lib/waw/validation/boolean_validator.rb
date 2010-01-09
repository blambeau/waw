module Waw
  module Validation
    class BooleanValidator < Validator
    
      def is_boolean?(value)
        value==true || value==false
      end
    
      def to_boolean(value)
        return value if validate(value)
        case value
          when 'true'
            true
          when 'false'
            false
          else 
            raise ArgumentError, "Unable to convert #{value} to a Boolean"
        end 
      end
    
      def validate(*values)
        values.all?{|val| is_boolean?(val)}
      end
      alias :=== :validate
    
      def convert_and_validate(*values)
        ok = values.all?{|val| validate(val) || /^true$|^false$/ =~ val.to_s.strip}
        ok ? [true, values.collect{|val| to_boolean(val)}] : [false, values]
      end
    
    end # class BooleanValidator
  end # module Validation
end # module Waw
