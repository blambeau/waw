require 'test/unit'
require 'waw/utils/dsl_helper'

# Tests the DSLHelper class
class DSLHelperTest < Test::Unit::TestCase
  
  # Ensures an expanded path on a test-relative file
  def relative(file)
    File.join(File.dirname(__FILE__), file)
  end
  
  # Tests some test hypotheses
  def test_hypotheses
    assert_equal true, String.method_defined?(:upcase)
    assert_equal false, String.method_defined?(:a_method_that_doesnt_exists)
  end
  
  # Tests DSLHelper.is_intrusive?
  def test_is_intrusive?
    assert_equal true, DSLHelper.is_intrusive?(String => [:upcase])
    assert_equal true, DSLHelper.is_intrusive?(String => [:upcase, :a_method_that_doesnt_exists])
    assert_equal false, DSLHelper.is_intrusive?(String => [:a_method_that_doesnt_exists])
    assert_equal true, DSLHelper.is_intrusive?(String => [:upcase], DSLHelperTest => [:test_hypotheses])
    assert_equal true, DSLHelper.is_intrusive?(String => [:a_method_that_doesnt_exists], DSLHelperTest => [:test_hypotheses])
    assert_equal false, DSLHelper.is_intrusive?(String => [:a_method_that_doesnt_exists], DSLHelperTest => [:a_method_that_doesnt_exists])
  end
  
  # Tests DSLHelper.find_instance_method
  def test_find_instance_method
    assert_not_nil DSLHelper.find_instance_method(String, :upcase)
    assert_nil DSLHelper.find_instance_method(String, :a_method_that_doesnt_exists)
  end
  
  # Tests dry usage of the class
  def test_dry_usage
    DSLHelper.new(String => [:upcase, :downcase]) do 
      Kernel.load relative('dsl_helper_test_extensions1.rb')
      assert_equal "hello", "hello".upcase
      assert_equal "HELLO", "HELLO".downcase
    end
    assert_equal "HELLO", "hello".upcase
    assert_equal "hello", "HELLO".downcase
  end
  
  # Tests normal usage of the class
  def test_normal_usage
    helper = DSLHelper.new(String => [:upcase, :downcase])
    2.times do
      helper.save
        Kernel.load relative('dsl_helper_test_extensions1.rb')
        assert_equal "hello", "hello".upcase
        assert_equal "HELLO", "HELLO".downcase
      helper.restore
      assert_equal "HELLO", "hello".upcase
      assert_equal "hello", "HELLO".downcase
    end
  end
  
  # Tests that bad usage leads to friendly errors
  def test_it_handles_bad_usage_friendly
    helper = DSLHelper.new(String => [:upcase, :downcase])
    assert_nothing_raised do helper.save end
    assert_raise RuntimeError do helper.save end
    assert_nothing_raised do helper.restore end
  end
  
  # Tests stability of usage errors
  def test_it_is_stable_to_usage_errors
    helper = DSLHelper.new(String => [:upcase, :downcase])
    helper.save
    Kernel.load relative('dsl_helper_test_extensions1.rb')
    assert_equal "hello", "hello".upcase
    assert_raise RuntimeError do helper.save end
    assert_equal "hello", "hello".upcase
    assert_nothing_raised do helper.restore end
    assert_equal "HELLO", "hello".upcase
  end
  
end