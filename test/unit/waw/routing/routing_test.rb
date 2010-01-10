require 'test/unit'
require 'waw'
module Waw
  class RoutingTest < Test::Unit::TestCase
    include Waw::Routing::Methods
    
    def test_installation_on_routing_itself
      result = ["success", "ok"]
      assert Routing.matches?(result, "success/ok")
      assert Routing.matches?(result, "success/*")
      result = ["success", ["ok"]]
      assert Routing.matches?(result, "success/ok")
      assert Routing.matches?(result, "success/*")
    end
    
    def test_matches
      result = ["success", "ok"]
      assert matches?(result, "success/ok")
      assert matches?(result, "success/*")
      result = ["success", ["ok"]]
      assert matches?(result, "success/ok")
      assert matches?(result, "success/*")
    end
    
  end
end