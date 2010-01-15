require 'test/unit'
require 'waw'
module Waw
  module Controllers
    class ActionController < ::Waw::Controller
      class ActionTest < Test::Unit::TestCase
        
        class A < ::Waw::ActionController
          
          signature{}
          def hello(params)
          end
          
          def self.url
            "/services"
          end
          def url
            "/services"
          end
          
        end
        
        def test_id
          assert_equal "services_hello", A.hello.id
        end
        
        def test_href
          assert_equal "/services/hello", A.hello.href
          assert_equal "/services/hello?who=blambeau", A.hello.href(:who => 'blambeau')
        end
        
      end
    end
  end
end