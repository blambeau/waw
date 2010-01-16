require 'waw/validation/validator'
require 'waw/validation/not_validator'
require 'waw/validation/and_validator'
require 'waw/validation/or_validator'
require 'waw/validation/missing_validator'
require 'waw/validation/mandatory_validator'
require 'waw/validation/comparison_validations'
require 'waw/validation/size_validations'
require 'waw/validation/array_validations'
require 'waw/validation/default_validator'
require 'waw/validation/integer_validator'
require 'waw/validation/boolean_validator'
require 'waw/validation/file_validator'
require 'waw/validation/ext'
require 'waw/validation/signature'
module Waw
  #
  # Provides a reusable architecture for parameter validation 
  #
  module Validation
    
    # Validators, by name
    @@validators = {}
    
    # Validation kernel
    class << self

      # Checks if a given value is considered missing. In a web environment,
      # we consider a value being missing when it is nil or an empty string
      # (when stripped). All validators should use this method to share a 
      # common definition for 'missing'. It may be overriden, at your own 
      # risks however. This method always returns false when invoked on 
      # any value other than nil or a String.
      def is_missing?(value)
        value.nil? or (String===value and value.strip.empty?)
      end
      
      # Automatically converts specials guys as validators (regular 
      # expressions, some ruby classes, etc.)
      def to_validator(who)
        case who
          when Regexp
            validator {|*values| values.all?{|val| who =~ val}}
          else
            nil
        end
      end
    
      # Builds a validator with a given block as validation code
      def validator(&block)
        Validator.new(&block)
      end

      # Builds a signature with a given block as definition
      def signature(&block)
        Signature.new(&block)
      end

    end # Validation kernel
    
    # Helpers for extensions
    class << self
      
      # Automatically builds the validator and installs a method returning
      # it.
      def method_missing(name, *args, &block)
        # We only accept self.something= for validator installation
        return super(name, *args, &block) unless /\=$/ =~ name.to_s
        
        # The, different cases
        name = name.to_s[0...-1].to_sym
        if (args.size==1) and (::Waw::Validation::Validator===args[0]) and block.nil?
          # first case: explicit validator
          the_validator = args[0]
        elsif (args.size==1) and block.nil?
          # second case: auto conversion
          the_validator = to_validator(args[0])
        end

        if the_validator
          # Install the validator in the collection
          @@validators[name] = the_validator

          # Installs the class method that returns the validator
          instance_eval <<-EOF
            class << self
              def #{name}
                @@validators[:#{name}]
              end
            end
          EOF
        else
          raise WawError, "Unable to install validator #{name} with #{args.inspect} and #{block.inspect}"
        end
      end
      
    end # Helpers for extensions
  
    # Validators typically used for parameter validation
    def self.default(default_value) DefaultValidator.new(default_value); end
    self.missing    =  ::Waw::Validation::MissingValidator.new
    self.mandatory  =  ::Waw::Validation::MandatoryValidator.new
    self.mail       =  /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
    self.weburl     =  /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    self.equal      =  validator{|*args| args.uniq.size==1}

    # Validators normally used elsewhere
    self.directory  =  validator{|*args| args.all?{|a| ::File.directory?(a)}}
    def self.file(opts = nil) FileValidator.new(opts); end

    # Validators about size
    def self.size() SizeValidations; end

    # Validators about comparisons
    Comparison = ComparisonValidations.new
    def self.is() Comparison; end

    # Validators about size
    Array = ArrayValidations.new
    def self.array() Waw::Validation::Array; end
  
    # Integer validation
    Integer = IntegerValidator.new
    def self.integer() Waw::Validation::Integer; end
  
    # Boolean validation
    Boolean = BooleanValidator.new
    def self.boolean() Waw::Validation::Boolean; end

  end # module Validation
end # module Waw