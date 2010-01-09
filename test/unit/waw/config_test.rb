require 'waw'
require 'test/unit'
module Waw
  class ConfigTest < Test::Unit::TestCase
    
    def test_default_config
      c = Config.new
      assert_equal 'logs', c.log_dir
      assert_equal 'weekly', c.log_frequency
      assert_equal Logger::DEBUG, c.log_level
      assert_equal [Waw::Services::PublicPages], c.waw_services
      assert_equal ['logs'], c.log_dir(true)
      assert_equal [Waw::Services::PublicPages], c.waw_services(true)
    end
    
  end
end