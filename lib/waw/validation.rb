require 'waw/validation/validator'
require 'waw/validation/not_validator'
require 'waw/validation/and_validator'
require 'waw/validation/or_validator'
require 'waw/validation/comparison_validations'
require 'waw/validation/size_validations'
require 'waw/validation/array_validations'
require 'waw/validation/missing_validator'
require 'waw/validation/default_validator'
require 'waw/validation/integer_validator'
require 'waw/validation/boolean_validator'
require 'waw/validation/ext'
require 'waw/validation/signature'
module Waw
  #
  # Provides a reusable architecture for parameter validation 
  #
  module Validation
  
    # Checks if a given value is considered missing
    def self.is_missing?(value)
      value.nil? or (String===value and value.strip.empty?)
    end
    
    # Builds a validator with a given block as validation code
    def self.validator(&block)
      Validator.new(&block)
    end

    # Builds a signature with a given block as definition
    def self.signature(&block)
      Signature.new(&block)
    end

    # Validator/Converter for missing values
    Missing = MissingValidator.new
    def self.missing() Missing; end
  
    # Validator for mandatory values
    Mandatory = Missing.not
    def self.mandatory() Mandatory; end
  
    # Default validator
    def self.default(default_value) DefaultValidator.new(default_value); end
  
    # Validator for a mail adress
    Mail = /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/.to_validator
    def self.mail() Mail; end

    WebUrl = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix.to_validator
    def self.weburl() WebUrl; end

    # Checks that the argument matches a folder
    IsDirectory = Validation.validator{|*args| args.all?{|a| ::File.directory?(a)}}
    def directory() IsDirectory; end

    # Checks that the argument matches a folder
    IsFile = Validation.validator{|*args| args.all?{|a| ::File.file?(a)}}
    def file() IsFile; end

    # Alls passed arguments are equal
    Equal = validator{|*args| args.uniq.size==1}
    def self.equal() Equal; end

    # Validators about size
    Size = SizeValidations.new
    def self.size() Size; end

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