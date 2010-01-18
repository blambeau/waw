require 'waw'
require 'test/unit'
module Waw
  class RubyExtensionTest < Test::Unit::TestCase
    
    def test_hash_keep
      hash = {:name => "blambeau", :age => 20}
      assert_equal({:name => "blambeau"}, hash.keep(:name))
      assert_equal(hash, hash.keep(:name, :age))
      assert_equal false, hash.object_id==hash.keep(:name, :age).object_id
      assert_equal hash, hash.keep(:name, :age, :occupation)
    end
    
    def test_hash_to_url_query
      hash = {}
      assert_equal "", hash.to_url_query
      hash = {:name => "blambeau"}
      assert_equal "name=blambeau", hash.to_url_query
      hash = {:name => "blambeau", :age => 12}
      assert ["name=blambeau&age=12", "age=12&name=blambeau"].include?(hash.to_url_query)
      hash = {:name => "bla&beau"}
      assert_equal "name=bla%26beau", hash.to_url_query
    end
    
  end
end