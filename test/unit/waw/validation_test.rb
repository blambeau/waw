require 'waw/validation'
require 'test/unit'
module Waw
  class ValidationTest < Test::Unit::TestCase
    
    def test_historical_first
      assert Waw::Validation.mandatory===false, "Waw::Validation.mandatory===false"
      assert Waw::Validation.mandatory===true, "Waw::Validation.mandatory===true"
      assert Waw::Validation.mandatory===0, "Waw::Validation.mandatory===0"
      assert Waw::Validation.mandatory===1, "Waw::Validation.mandatory===1"
      assert Waw::Validation.mandatory.not===nil, "Waw::Validation.mandatory.not===nil"
    
      assert (Waw::Validation.size > 0)==="12", "(Waw::Validation.size > 0)==='12'"
      assert (Waw::Validation.size > 0).not==="", "(Waw::Validation.size > 0).not==="
      assert (Waw::Validation.size >= 0)==="12", "(Waw::Validation.size >= 0)==='12'"
      assert (Waw::Validation.size >= 0)==="", "(Waw::Validation.size >= 0)==="
    
      assert (Waw::Validation.size > 0)===[:hello], "(Waw::Validation.size > 0)===[:hello]"
      assert (Waw::Validation.size > 0).not===[], "(Waw::Validation.size > 0).not===[]"
    
      assert (Waw::Validation.size == 0)===[]
      assert !((Waw::Validation.size == 10)===[])
    
      assert Waw::Validation::Array[String] === []
      assert Waw::Validation::Array[String] === ["coucou", "hello"]
      assert !(Waw::Validation::Array[String] === [12])
      assert !(Waw::Validation::Array[String] === ["coucou", 12])
      assert Waw::Validation::Array[Waw::Validation.size>2] === ["coucou", "hello"]
      assert !(Waw::Validation::Array[Waw::Validation.size>2] === ["coucou", "h"])
    end
    
    def test_equal
      assert_equal true, Waw::Validation.equal.validate(1, 1, 1, 1)
      assert_equal false, Waw::Validation.equal.validate(1, 1, 1, false)
      assert_equal true, Waw::Validation.equal.validate("pass", "pass")
      assert_equal false, Waw::Validation.equal.validate("pass", "pass2")
    end
    
    def test_missing
      assert ::Waw::Validation::Validator === Waw::Validation.missing
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
      val = (Waw::Validation.mandatory & Waw::Validation.validator{|v| v>10})
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