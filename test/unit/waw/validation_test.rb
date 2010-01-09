require 'waw/validation'
require 'test/unit'
module Waw
  class ValidationTest < Test::Unit::TestCase
    
    def test_historical_first
      assert Waw::Validation::Mandatory===false, "Waw::Validation::Mandatory===false"
      assert Waw::Validation::Mandatory===true, "Waw::Validation::Mandatory===true"
      assert Waw::Validation::Mandatory===0, "Waw::Validation::Mandatory===0"
      assert Waw::Validation::Mandatory===1, "Waw::Validation::Mandatory===1"
      assert Waw::Validation::Mandatory.not===nil, "Waw::Validation::Mandatory.not===nil"
    
      assert (Waw::Validation::Size > 0)==="12", "(Waw::Validation::Size > 0)==='12'"
      assert (Waw::Validation::Size > 0).not==="", "(Waw::Validation::Size > 0).not==="
      assert (Waw::Validation::Size >= 0)==="12", "(Waw::Validation::Size >= 0)==='12'"
      assert (Waw::Validation::Size >= 0)==="", "(Waw::Validation::Size >= 0)==="
    
      assert (Waw::Validation::Size > 0)===[:hello], "(Waw::Validation::Size > 0)===[:hello]"
      assert (Waw::Validation::Size > 0).not===[], "(Waw::Validation::Size > 0).not===[]"
    
      assert (Waw::Validation::Size == 0)===[]
      assert !((Waw::Validation::Size == 10)===[])
    
      assert Waw::Validation::Array[String] === []
      assert Waw::Validation::Array[String] === ["coucou", "hello"]
      assert !(Waw::Validation::Array[String] === [12])
      assert !(Waw::Validation::Array[String] === ["coucou", 12])
      assert Waw::Validation::Array[Waw::Validation::Size>2] === ["coucou", "hello"]
      assert !(Waw::Validation::Array[Waw::Validation::Size>2] === ["coucou", "h"])
    end
    
    def test_equal
      assert_equal true, Waw::Validation::Equal.validate(1, 1, 1, 1)
      assert_equal false, Waw::Validation::Equal.validate(1, 1, 1, false)
      assert_equal true, Waw::Validation::Equal.validate("pass", "pass")
      assert_equal false, Waw::Validation::Equal.validate("pass", "pass2")
    end
    
    def test_validator
      validator = Waw::Validation.validator{|val| Integer===val and val>10}
      assert_equal true, validator===11
      assert_equal false, validator===10
      assert_equal false, validator===7
      assert_equal false, validator==="10"
    end
    
    def test_validator_accepts_multiple_arguments
      validator = Waw::Validation.validator{|val1, val2| val1==val2}
      assert_equal true, validator.validate("hello", "hello")
      assert_equal false, validator.validate("hello", 10)
      assert_equal true, validator.validate(10, 10)
    end
    
    def test_validator_conjunction
      val = (Waw::Validation::Mandatory & Waw::Validation.validator{|v| v>10})
      assert_equal true, val===11
      assert_equal false, val===10
      assert_equal false, val===nil
    end
    
    def test_validator_disjunction
      val = (Waw::Validation::validator{|v| v<10} | Waw::Validation.validator{|v| v>10})
      assert_equal true, val===11
      assert_equal false, val===10
      assert_equal true, val===9
    end
    
    # def test_to_validator_on_module
    #   assert_equal true, String.to_validator==="blambeau"
    #   assert_equal false, Integer.to_validator==="blambeau"
    #   assert_equal true, Integer.to_validator===10
    # end
    
    def test_to_validator_on_regexp
      assert_equal true, /[a-z]+/.to_validator==="blambeau"
      assert_equal false, /[a-z]+/.to_validator==="12339"
    end
    
  end
end