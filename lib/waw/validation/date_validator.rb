require 'date'
module Waw
  module Validation
    class DateValidator < Validator
    
      # Returns a Date object if value seems a date,
      # nil otherwise
      def seems_a_date?(value)
        if /^\d{4}\/\d{2}\/\d{2}$/ =~ value.to_s
          Date.strptime(value.to_s, "%Y/%m/%d")
        elsif /^\d{2}\/\d{2}\/\d{4}$/ =~ value.to_s
          Date.strptime(value.to_s, "%d/%m/%Y")
        else
          nil
        end
      rescue ArgumentError => ex
        nil
      end
    
      def validate(*values)
        values.all?{|val| seems_a_date?(val)}
      end
    
      def convert_and_validate(*values)
        dates = values.collect{|v| seems_a_date?(v)}
        dates.include?(nil) ? [false, values] : [true, dates]
      end
    
    end # class IntegerValidator
  end # module Validation
end # module Waw
