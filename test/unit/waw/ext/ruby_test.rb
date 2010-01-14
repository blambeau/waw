require 'waw'
require 'test/unit'
module Waw
  class RubyExtensionTest < Test::Unit::TestCase
    
    def test_hash_keep
      hash = {:name => "blambeau", :age => 20}
      assert_equal({:name => "blambeau"}, hash.keep(:name))
      assert_equal(hash, hash.keep(:name, :age))
      assert_equal false, hash.object_id==hash.keep(:name, :age)
      assert_equal hash, hash.keep(:name, :age, :occupation)
    end
    
  end
end