module Waw
  module Validation
    module Helpers
      
      # Sends a friendly error message if something is wrong
      def error(msg, the_caller)
        raise ::Waw::WawError, msg, the_caller
      end
      
      # Checks if a given value is considered missing. In a web environment,
      # we consider a value being missing when it is nil or an empty string
      # (when stripped). All validators should use this method to share a 
      # common definition for 'missing'. It may be overriden, at your own 
      # risks however. This method always returns false when invoked on 
      # any value other than nil or a String.
      def is_missing?(value)
        value.nil? or (String===value and value.strip.empty?)
      end
      
      # Converts missing values to nil
      def missings_to_nil(values)
        values.collect{|v| is_missing?(v) ? nil : v}
      end
      
      # Checks if all values are missing
      def all_missing?(values)
        values.all?{|v| is_missing?(v)}
      end
      
      # Checks if any value is missing
      def any_missing?(values)
        values.any?{|v| is_missing?(v)}
      end
      
      # Checks if no value is considered missing
      def no_missing?(values)
        not(any_missing?(values))
      end
      
      # Yields the block inside a rescue on ArgumentError. Returns false
      # if such an error has been raised
      def argument_safe
        yield
      rescue ArgumentError
        false
      end
      
      # Automatically converts specials guys as validators (regular 
      # expressions, some ruby classes, etc.)
      def to_validator(who)
        case who
          when ::Waw::Validation::Validator
            who
          when Regexp
            RegexpValidator.new(who, true)
          else
            raise "Unable to convert #{who} to a validator"
        end
      end

    end # module Helpers
  end # module Validation
end # module Waw