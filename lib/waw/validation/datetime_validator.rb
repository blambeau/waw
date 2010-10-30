require 'date'
require 'time'
module Waw
  module Validation
    class DateTimeValidator < Validator
    
      # Creates a validator instance with options
      def initialize(options = {})
        @options = options
      end
      
      def date_format
        @options[:date_format] || '%Y/%m/%d'
      end
    
      # Returns a Date object if value seems a date, nil otherwise
      def seems_a_date?(value)
        Date.strptime(value.to_s, date_format)
      rescue ArgumentError => ex
        nil
      end
    
      # Returns a Date object if value seems a date, nil otherwise
      def seems_a_time?(value, date)
        if value.to_s.empty?
          false
        else
          Time.parse(value.to_s, date)
        end
      rescue ArgumentError => ex
        nil
      end
    
      def validate(*values)
        convert_and_validate(*values)[0]
      end
    
      def convert_and_validate(*values)
        date = seems_a_date?(values[0])
        if date.nil?
          [false, values]
        else
          if time = seems_a_time?(values[1], date)
            [true, [date, time]]
          else
            [false, values]
          end
        end
      end
    
    end # class DateTimeValidator
  end # module Validation
end # module Waw
