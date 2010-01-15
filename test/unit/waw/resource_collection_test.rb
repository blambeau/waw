require 'waw'
require 'test/unit'
module Waw
  class ResourceCollectionTest < Test::Unit::TestCase
    
    class Trash
      def self.write(*args) end
      def self.close(*args) end
    end
    def setup
      Waw.logger = Logger.new(Trash)
    end
    
    def test_resources_on_string
      r = ResourceCollection.parse_resources <<-EOF
        first_one  "Hello world"
        second_one 2
        third_one 2*33
      EOF
      assert r.has_resource?(:first_one)
      assert_equal "Hello world", r.first_one
      assert_equal "Hello world", r[:first_one]
      assert_equal 2, r.second_one
      assert_equal 66, r.third_one
      assert !r.has_resource?(:missing)
    end
    
    def test_resources_on_file
      r = ResourceCollection.parse_resource_file(File.join(File.dirname(__FILE__), 'resources.txt'))
      assert r.has_resource?(:first_one)
      assert_equal "Hello world", r.first_one
      assert_equal "Hello world", r[:first_one]
      assert_equal 2, r.second_one
      assert_equal 66, r.third_one
      assert !r.has_resource?(:missing)
    end
    
    def test_on_missing_resources
      r = ResourceCollection.parse_resources <<-EOF
        first_one  "Hello world"
        second_one 2
        third_one 2*33
      EOF
      assert_equal nil, r.hello
      assert_equal "world", r.hello("world")
    end
    
  end
end