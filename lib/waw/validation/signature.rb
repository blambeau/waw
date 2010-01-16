module Waw
  module Validation
    #
    # A service or data signature, as a list of validations to be respected.
    #
    class Signature
    
      # The DSL attached to signature
      class DSL
      
        # Creates a DSL instance
        def initialize(signature)
          @signature = signature
        end
      
        # Adds a validation
        def validation(args, validator, onfailure)
          @signature.add_validation(args, ::Waw::Validation.to_validator(validator), onfailure)
        end
      
        # When a methos is missing
        def method_missing(name, *args, &block)
          Waw::Validation.send(name, *args, &block)
        rescue Exception => ex
          raise ex.class, ex.message, caller
        end
      
      end # class DSL
    
      # A validation rule
      class ValidationRule
      
        # Creates a Validation instance
        def initialize(args, validator, onfailure)
          @args = args
          @validator = validator
          @onfailure = onfailure
        end
        
        # Collects the interesting parameters on a hash
        def collect_on_hash(hash)
          @args.collect{|arg| hash[arg]}
        end
      
        # Validates argument values given through a hash. Returns nil
        # if everything is ok, the on_failure installed parameters otherwise.
        def validate(hash)
          @validator.validate(*collect_on_hash(hash)) ? nil : @onfailure
        end
      
        # Validates and convert a hash. Values of the hash are replaced
        # by their convertions if the validation passes. In this case, a
        # nil value is returned. Otherwise, the on_failure is returned 
        # and the hash is not changed.
        def convert_and_validate(hash)
          ok, values = @validator.convert_and_validate(*collect_on_hash(hash))
          @args.each_with_index {|arg, i| hash[arg] = values[i]} if ok
          ok ? nil : @onfailure
        end
        
        # Applies the validation and conversion rule on a hash. Returns the
        # first converted (or non converted if validation fails) value.
        def first_converted(hash)
          ok, values = @validator.convert_and_validate(*collect_on_hash(hash))
          values[0]
        end
      
      end # class Validation
    
      # Rules
      attr_accessor :rules
    
      # Creates an empty signature
      def initialize(&block)
        @rules = []
        DSL.new(self).instance_eval(&block) unless block.nil?
      end
    
      # Merges this signature with additional definition
      def merge(&block)
        signature = self.dup
        DSL.new(signature).instance_eval(&block) unless block.nil?
        signature
      end
    
      # Adds a validation rule
      def add_validation(args, validator, onfailure)
        args = [args] if Symbol===args
        @rules << ValidationRule.new(args, validator, onfailure)
      end
    
      # Validates argument values given through a hash and returns a series
      # of onfailure flags.
      def validate(hash)
        converted, failures = hash.dup, []
        failures = @rules.collect{|rule| rule.validate(converted)}.compact
        failures.empty? ? [true, converted] : [false, failures]
      end
    
      # Validates argument values given through a hash and returns a series
      # of onfailure flags.
      def apply(hash)
        converted, failures = hash.dup, []
        failures = @rules.collect{|rule| rule.convert_and_validate(converted)}.compact
        failures.empty? ? [true, converted] : [false, failures]
      end
      
      # Calls first_converted(hash) on the first rule. Returns nil if no rule
      # has been installed. The hash is never modified by this method.
      def first_converted(hash = {})
        return nil if @rules.nil? or @rules.empty?
        @rules[0].first_converted(hash)
      end
      
      # Checks if the signature allows passing with some values 
      def allows?(hash={})
        apply(hash)[0]
      end
      
      # Checks if the signature blocks with some values 
      def blocks?(hash={})
        not(allows?(hash))
      end
    
      # Duplicates this validation
      def dup
        copy = Signature.new
        copy.rules = self.rules.dup
        copy
      end
    
      protected :rules=
    end # class Signature
  end # module Validation
end # module Waw
