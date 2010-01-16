require 'waw'
require 'test/unit'
module Waw
  class ValidationTest < Test::Unit::TestCase
    
    MISSING     = [nil, "", " ", "  "]
    NOT_MISSING = [self, 0, -1, 1, 12.0, -1000, true, false, "hello"]
    MIX         = (MISSING + NOT_MISSING)
    
    def method_missing(name, *args, &block)
      Waw::Validation.send(name, *args, &block)
    end
    
    def test_is_missing?
      assert MISSING.all?{|v| is_missing?(v)}
      assert !NOT_MISSING.any?{|v| is_missing?(v)}
    end
    
    def test_all_missing?
      assert all_missing?(MISSING)
      assert !all_missing?(NOT_MISSING)
      assert !all_missing?(MIX)
    end
    
    def test_any_missing?
      assert any_missing?(MISSING)
      assert !any_missing?(NOT_MISSING)
      assert any_missing?(MIX)
    end
    
    def test_no_missing?
      assert no_missing?(NOT_MISSING)
      assert !no_missing?(MISSING)
      assert !no_missing?(MIX)
    end
    
    def test_missings_to_nil
      assert_equal MISSING.collect{|v| nil}, missings_to_nil(MISSING)
      assert_equal NOT_MISSING, missings_to_nil(NOT_MISSING)
    end
    
    def test_missing
      assert Waw::Validation::Validator===missing
      assert !NOT_MISSING.any?{|v| missing===v}
      assert MISSING.all?{|v| missing===v}
      NOT_MISSING.each do |val|
        assert_equal [false, [val]], missing =~ val
      end
      MISSING.each do |val|
        assert_equal [true, [nil]], missing =~ val
      end
      assert_equal [false, [self, nil]], missing.=~(self, nil)
      assert_equal [false, [nil, self]], missing.=~(nil, self)
      assert_equal [true, [nil, nil, nil]], missing.=~("   ", " ", nil)
    end
    
    def test_mandatory
      assert Waw::Validation::Validator===mandatory
      assert NOT_MISSING.all?{|v| mandatory===v}
      assert !MISSING.any?{|v| mandatory===v}
      NOT_MISSING.each do |val|
        assert_equal [true, [val]], mandatory =~ val
      end
      MISSING.each do |val|
        assert_equal [false, [val]], mandatory =~ val
      end
    end
    
    def test_default
      assert_raise ::Waw::WawError do
        ::Waw::Validation.default
      end
      assert ::Waw::Validation::Validator === default(12)
      assert MISSING.all?{|v| default("ok")===v} 
      assert !NOT_MISSING.any?{|v| default("ok")===v} 
      NOT_MISSING.each do |val|
        assert_equal [false, [val]], default("ok") =~ val
      end
      MISSING.each do |val|
        assert_equal [true, ["ok"]], default("ok") =~ val
      end
      assert_equal [false, [nil, 12]], default("ok").=~(nil, 12)
      assert_equal [false, ["", 12]], default("ok").=~("", 12)
    end
    
    def test_same
      assert ::Waw::Validation::Validator === same
      assert NOT_MISSING.all?{|v| same.===(v,v)}
      assert !MISSING.any?{|v| same.===(v,v)}
      assert same.===(12, 12)
      assert same.===(12, 12, 12)
      assert !same.===(12, 13)
      assert !same.===(12, 12, 13)
      assert !same.===(12, nil)
      assert !same.===(nil, nil)
      assert_equal [true, [12, 12]], same.=~(12, 12)
      assert_equal [false, [12, ""]], same.=~(12, "")
      assert_equal [false, [12, nil]], same.=~(12, nil)
    end
    
    def test_isin
      assert ::Waw::Validation::Validator === isin
      MIX.each do |val|
        assert_equal false, isin(101, "not present", /^$/)===val
        assert_equal true, isin(val)===val
      end
      assert_equal true, isin(nil)===nil
      assert_equal true, isin("hello", "world")==="hello"
      assert_equal true, isin("hello", "world")==="world"
      assert_equal [true, ["hello", "world"]], isin("hello", "world", "happy").=~("hello", "world")
      assert_equal [false, ["hello", "world"]], isin("hell", "world", "happy").=~("hello", "world")
    end
    
    def test_boolean
      assert [true, false].all?{|v| boolean===v}
      assert !MISSING.any?{|v| boolean === v}
      assert !NOT_MISSING.all?{|v| boolean === v}
      assert_equal [true, [true, false]], boolean.=~(true, false)
      assert_equal [true, [true, false]], boolean.=~('true', false)
      assert_equal [true, [true, false]], boolean.=~(' true  ', false)
      assert_equal [true, [true, false]], boolean.=~(' true  ', "false   ")
      assert_equal [false, [self]], boolean.=~(self)
    end
    
    def test_integer
      assert [1, 12, 0].all?{|v| integer===v}
      assert !MISSING.any?{|v| integer===v}
      assert !NOT_MISSING.all?{|v| integer===v}
      assert !["hello", self].any?{|v| integer===v}
      assert_equal [true, [0, 12]], integer.=~(0, 12)
      assert_equal [true, [0, 12]], integer.=~('0', 12)
      assert_equal [true, [0, 12]], integer.=~('    0   ', 12)
      assert_equal [true, [0, 12]], integer.=~('0', '12')
      assert_equal [true, [0, 12]], integer.=~('+0', '+12')
      assert_equal [true, [0, -12]], integer.=~('+0', '-12')
      assert_equal [false, ['0', nil]], integer.=~('0', nil)
      assert_equal [false, [0, nil]], integer.=~(0, nil)
      assert_equal [false, [0, ""]], integer.=~(0, "")
      assert_equal [false, ['hello']], integer.=~('hello')
      assert_equal [false, ['hello12']], integer.=~('hello12')
      assert_equal [false, [self]], integer.=~(self)
    end
    
    def test_float
      assert [1.0, 0.0, -10.0].all?{|v| float===v}
      assert !MISSING.any?{|v| float===v}
      assert !NOT_MISSING.all?{|v| float===v}
      assert_equal [true, [0.0, -12.0]], float.=~(0.0, -12.0)
      assert_equal [false, [0.0, nil]], float.=~(0.0, nil)
      assert_equal [true, [0.0, -12.0]], float.=~("0.0", "-12.0")
      assert_equal [true, [0.0, -12.0]], float.=~("0", "-12")
      assert_equal [true, [0.0, -12.0]], float.=~(".0", "-12.0")
      assert_equal [true, [0.2]], float.=~(".2")
      assert_equal [true, [1.2e3]], float.=~(1.2e3)
      assert_equal [true, [1.2e3]], float.=~("1.2e3")
      assert_equal [true, [1.2e3]], float.=~("1.2E3")
      assert_equal [true, [0.2e3]], float.=~(".2E3")
      assert_equal [false, [0.0, "hello"]], float.=~(0.0, "hello")
      assert_equal [false, [0.0, "h12.0"]], float.=~(0.0, "h12.0")
    end
    
    def test_mail
      ["blambeau@gmail.com", 
       "   blambeau@gmail.com   ",
       "x@fmail.com",
       "blambeau@acm-sc.be",
       "blambeau@info.uclouvain.be",
       "blambeau12@info.uclouvain.be",
       "blambeau12@info.uclouvain.be",
       "llambeau@hit-radio.be"].each do |v| 
         assert mail===v, "#{v} is a valid e-mail"
      end
      assert !MIX.any?{|v| mail===v}
      assert !(mail === "blambeuamail")
      assert !(mail === "blambeuamail@")
      assert !(mail === "@gmail.com")
      assert !(mail === "12")
    end
    
    def test_weburl
      ["http://www.google.com/",
       "https://www.google.com/",
       "http://www.google.com",
       "http://www.google.net",
       "https://www.google.com/some/path",
       "https://www.google.com/some/path?and=a&query=12",
       "https://www.google.com/some/path?and=a&query=12&that=",
       "https://www.google.com:9292/some/path?and=a&query=12&that=",
       "   https://www.google.com:9292/some/path?and=a&query=12&that=   ",
       ].each do |v|
         assert weburl===v, "#{v} is a valid web url"
      end
    end
    
    def test_size
      # just because it seems that a method size exists in Test::Unit::TestCase
      thesize = ::Waw::Validation.size
      assert_equal ::Waw::Validation::SizeValidations.object_id, thesize.object_id
      
      first, second = (::Waw::Validation::SizeValidations == 2), (::Waw::Validation::SizeValidations == 0)
      assert_equal false, first.object_id===second.object_id, "Different size validators"
      
      [(thesize == 2), (thesize <= 2), (thesize >= 2), (thesize < 2), (thesize > 2)].all?{|v| ::Waw::Validation::Validator===v}

      first, second = (thesize.==(2)), (thesize.==(0))
      assert_equal false, first.object_id===second.object_id, "Different size validators"
      
      assert ::Waw::Validation::SizeValidations.has_size?([])
      assert [].size <= 2
      
      assert (thesize == 0)===[], "Empty array has size == 0"
      ["  ", [1, 2]].each do |v|
        assert((thesize == 2).===(v), "|#{v}| has exactly a size of 2")
        assert(!(thesize == 3).===(v), "|#{v}| has not a size of 3")
        assert(((thesize <= 2)===v), "|#{v}| has size <= 2")
        assert(((thesize >= 2)===v), "|#{v}| has size >= 2")
        assert(!((thesize > 2)===v), "|#{v}| has not size > 2")
        assert(!((thesize < 2)===v), "|#{v}| has not size < 2")
      end
      MISSING.each do |v|
        assert_equal false, (thesize==100).===(v)
        #assert_equal false, (thesize<=100).===(v) # not true because of ""
        assert_equal false, (thesize>=100).===(v)
        #assert_equal false, (thesize<100).===(v) # not true because of ""
        assert_equal false, (thesize>100).===(v)
      end
      assert_nothing_raised do
        assert_equal false, Object.new.respond_to?(:size)
        assert_equal false, (thesize>100).===(Object.new)
        assert_equal false, (thesize>self).===(Object.new)
        assert_equal false, (thesize>"hello").===(Object.new)
        assert_equal false, (thesize>self).===("  ")
        assert_equal false, (thesize>"hello").===("  ")
      end
    end
    
    def test_is
      # Ensure that we are talking about the validator
      assert_equal false, self.respond_to?(:is)
      assert ::Waw::Validation::ComparisonValidations.object_id==is.object_id
      assert ::Waw::Validation::Validator===(is==2)
      MISSING.each do |val|
        assert_equal false, (is==345678)===val
        assert_equal false, (is<=345678)===val
        assert_equal false, (is>=345678)===val
        assert_equal false, (is<345678)===val
        assert_equal false, (is>345678)===val
      end
      assert_equal true, (is == 2)===2
      assert_equal true, (is <= 2)===2
      assert_equal true, (is >= 2)===2
      assert_equal true, (is < 2)===1
      assert_equal true, (is > 2)===3
      assert_equal false, (is > 2)==="hello"
      assert_equal [true, [3]], (is < 10) =~ 3
      assert_equal [false, ["hello"]], (is < 10) =~ "hello"
      assert_equal [false, ["3"]], (is < 10) =~ "3"
      assert_equal true, is.in(1, 2, 3)===3
      assert_equal false, is.in(1, 2, 3)===4
      assert_equal [true, [1, 2]], is.in(1, 2, 3).=~(1, 2) 
    end
        
    def test_historical_first
      assert Waw::Validation.mandatory===false, "Waw::Validation.mandatory===false"
      assert Waw::Validation.mandatory===true, "Waw::Validation.mandatory===true"
      assert Waw::Validation.mandatory===0, "Waw::Validation.mandatory===0"
      assert Waw::Validation.mandatory===1, "Waw::Validation.mandatory===1"
      assert Waw::Validation.mandatory.not===nil, "Waw::Validation.mandatory.not===nil"
    
      # assert (Waw::Validation.size > 0)==="12", "(Waw::Validation.size > 0)==='12'"
      # assert (Waw::Validation.size > 0).not==="", "(Waw::Validation.size > 0).not==="
      # assert (Waw::Validation.size >= 0)==="12", "(Waw::Validation.size >= 0)==='12'"
      # assert (Waw::Validation.size >= 0)==="", "(Waw::Validation.size >= 0)==="
      #     
      # assert (Waw::Validation.size > 0)===[:hello], "(Waw::Validation.size > 0)===[:hello]"
      # assert (Waw::Validation.size > 0).not===[], "(Waw::Validation.size > 0).not===[]"
      #     
      # assert (Waw::Validation.size == 0)===[]
      # assert !((Waw::Validation.size == 10)===[])
    
      assert Waw::Validation::Array[String] === []
      assert Waw::Validation::Array[String] === ["coucou", "hello"]
      assert !(Waw::Validation::Array[String] === [12])
      assert !(Waw::Validation::Array[String] === ["coucou", 12])
      assert Waw::Validation::Array[Waw::Validation.size>2] === ["coucou", "hello"]
      assert !(Waw::Validation::Array[Waw::Validation.size>2] === ["coucou", "h"])
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
    
  end
end