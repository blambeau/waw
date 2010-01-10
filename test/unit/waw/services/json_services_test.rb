require 'test/unit'
require 'waw'
module Waw
  module Services
    class JSONServicesTest < Test::Unit::TestCase
      include Waw::Services::JSONServices::Utils
      
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
end