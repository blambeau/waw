require 'test/unit'
require 'rubygems'
require 'waw'
require 'rack'
module Waw
  class RackAssumtionsTest < Test::Unit::TestCase
    
    def test_static_new
      Rack::Static.new(nil, {:urls => ['doc', 'src'], 
                            :root => '/'})
    end
    
  end
end