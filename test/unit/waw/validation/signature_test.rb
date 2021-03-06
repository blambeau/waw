require 'waw'
require 'test/unit'
module Waw
  module Validation
    class SignatureTest < Test::Unit::TestCase
    
      def test_simple_case
        signature = Signature.new do 
          validation :name, Waw::Validation.mandatory, :missing_name
        end
        assert_equal [false, [:missing_name]], signature.apply(:name => nil)
        assert_equal [true, {:name => "blambeau"}], signature.apply(:name => "blambeau")
      end
    
      def test_supports_multiple_rules
        signature = Signature.new do 
          validation :name, Waw::Validation.mandatory, :missing_name
          validation :age, (Waw::Validation.mandatory & Waw::Validation.validator{|v| v>18}), :bad_age
        end
        assert_equal [false, [:missing_name, :bad_age]], signature.apply(:name => nil)
        assert_equal [false, [:bad_age]], signature.apply(:name => "blambeau", :age => nil)
        assert_equal [true, {:name => "blambeau", :age => 20}], signature.apply(:name => "blambeau", :age => 20)
      end
    
      def test_typical_web_scenario
        signature = Waw::Validation.signature do
          validation :mail, Waw::Validation.mail, :bad_email
          validation [:password, :confirm], Waw::Validation.same, :passwords_dont_match
          validation :age, Waw::Validation.missing | (Waw::Validation.integer & (Waw::Validation.is >= 18)), :bad_age
        end
    
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => 29)
        assert_equal({:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => 29}, values)
        assert_equal true, ok
          
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass2", :age => 29)
        assert_equal false, ok
        assert_equal [:passwords_dont_match], values
      
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass")
        assert_equal({:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => nil}, values)
        assert_equal true, ok
          
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => '')
        assert_equal({:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => nil}, values)
        assert_equal true, ok
          
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => "19")
        assert_equal({:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => 19}, values)
        assert_equal true, ok
      end

      def test_typical_web_scenario_sc2
        signature = Waw::Validation.signature do
          validation :mail, mail, :bad_email
          validation [:password, :confirm], same, :passwords_dont_match
          validation :age, (integer & (is >= 18)) | missing, :bad_age
          validation :newsletter, (boolean | default(false)), :bad_newsletter
        end
    
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => 29)
        assert_equal({:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => 29, :newsletter => false}, values)
        assert_equal true, ok
      
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => '29', :newsletter => nil)
        assert_equal({:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => 29, :newsletter => false}, values)
        assert_equal true, ok
      
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => '29', :newsletter => 'false')
        assert_equal({:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => 29, :newsletter => false}, values)
        assert_equal true, ok
      
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => '29', :newsletter => 'true')
        assert_equal({:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => 29, :newsletter => true}, values)
        assert_equal true, ok

        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass", :age => '29', :newsletter => 'hello')
        assert_equal false, ok
        assert_equal [:bad_newsletter], values
      end
    
      def test_typical_web_scenario_sc3
        signature = Waw::Validation.signature do
          validation :mail, mandatory & mail, :bad_email
          validation [:password, :confirm], mandatory & same, :passwords_dont_match
        end
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "pass", :confirm => "pass")
        assert_equal true, ok
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => "", :confirm => "")
        assert_equal false, ok
        assert_equal [:passwords_dont_match], values
        ok, values = signature.apply(:mail => "blambeau@gmail.com", :password => nil, :confirm => nil)
        assert_equal false, ok
        assert_equal [:passwords_dont_match], values
        ok, values = signature.apply(:mail => "blambeau@gmail.com")
        assert_equal false, ok
        assert_equal [:passwords_dont_match], values
      end
      
      def assert_signature_passes(expected, signature=nil, &block)
        signature = Waw::Validation.signature(&block) unless signature
        ok, converted = signature.apply(expected)
        assert_equal true, ok
        converted
      end
      
      def assert_signature_does_not_pass(expected, signature=nil, &block)
        signature = Waw::Validation.signature(&block) unless signature
        ok, converted = signature.apply(expected)
        assert_equal false, ok
        converted
      end
      
      def test_missing_and_default_intuition
        # mandatory mail
        get = assert_signature_passes(:mail => "blambeau@gmail.com") {
          validation :mail, mail, :bad_mail
        }
        assert_equal "blambeau@gmail.com", get[:mail]
        get = assert_signature_does_not_pass(:mail => nil) {
          validation :mail, mail, :bad_mail
        }
        assert_equal [:bad_mail], get
        get = assert_signature_does_not_pass(:mail => "") {
          validation :mail, mail, :bad_mail
        }
        assert_equal [:bad_mail], get
        get = assert_signature_does_not_pass(:mail => "blambeaugmail.com") {
          validation :mail, mail, :bad_mail
        }
        assert_equal [:bad_mail], get
        
        # optional valid mail
        get = assert_signature_passes(:mail => "blambeau@gmail.com") {
          validation :mail, mail | missing, :bad_mail
        }
        assert_equal "blambeau@gmail.com", get[:mail]
        get = assert_signature_passes(:mail => "blambeau@gmail.com") {
          validation :mail, missing | mail, :bad_mail
        }
        assert_equal "blambeau@gmail.com", get[:mail]
        get = assert_signature_passes(:mail => "") {
          validation :mail, mail | missing, :bad_mail
        }
        assert_equal nil, get[:mail]
        get = assert_signature_passes(:mail => nil) {
          validation :mail, missing | mail, :bad_mail
        }
        assert_equal nil, get[:mail]
        get = assert_signature_passes(:mail => nil) {
          validation :mail, mail | missing, :bad_mail
        }
        assert_equal nil, get[:mail]
        get = assert_signature_does_not_pass(:mail => "blambeaugmail.com") {
          validation :mail, mail | missing, :bad_mail
        }
        assert_equal [:bad_mail], get
        
        # optional valid mail, with default
        get = assert_signature_passes(:mail => "blambeau@gmail.com") {
          validation :mail, mail | default("info@gmail.com"), :bad_mail
        }
        assert_equal "blambeau@gmail.com", get[:mail]

        get = assert_signature_passes(:mail => "blambeau@gmail.com") {
          validation :mail, default("info@gmail.com") | mail, :bad_mail
        }
        assert_equal "blambeau@gmail.com", get[:mail]

        get = assert_signature_passes(:mail => nil) {
          validation :mail, mail | default("info@gmail.com"), :bad_mail
        }
        assert_equal "info@gmail.com", get[:mail]

        get = assert_signature_passes(:mail => nil) {
          validation :mail, default("info@gmail.com") | mail, :bad_mail
        }
        assert_equal "info@gmail.com", get[:mail]

        get = assert_signature_passes(:mail => "    ") {
          validation :mail, mail | default("info@gmail.com"), :bad_mail
        }
        assert_equal "info@gmail.com", get[:mail]

        get = assert_signature_does_not_pass(:mail => "blambeaugmail.com") {
          validation :mail, mail | default("info@gmail.com"), :bad_mail
        }
        assert_equal [:bad_mail], get
      end
    
    end
  end
end