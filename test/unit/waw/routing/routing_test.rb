require 'test/unit'
require 'waw'
module Waw
  class RoutingTest < Test::Unit::TestCase
    include Waw::Routing::Methods
    
    def test_installation_on_routing_itself
      result = ["success", "ok"]
      assert Routing.matches?("success/ok", result)
      assert Routing.matches?("success/*", result)
      result = ["success", ["ok"]]
      assert Routing.matches?("success/ok", result)
      assert Routing.matches?("success/*", result)
    end
    
    def test_matches
      result = ["success", "ok"]
      assert matches?("success/ok", result)
      assert matches?("success/*", result)
      result = ["success", ["ok"]]
      assert matches?("success/ok", result)
      assert matches?("success/*", result)
    end
    
  end
end