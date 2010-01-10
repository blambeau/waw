require 'waw'
require 'test/unit'
module Waw
  class ConfigTest < Test::Unit::TestCase
    
    def test_default_config
      c = Config.new(false).merge <<-EOF
        log_dir   'logs'
        log_frequency 'weekly'
        log_level   Logger::DEBUG
      EOF
      assert_equal 'logs', c.log_dir
      assert_equal 'weekly', c.log_frequency
      assert_equal Logger::DEBUG, c.log_level
      assert_equal ['logs'], c.log_dir(true)
    end
    
    def test_config_allows_future_references
      c = Config.new(false)
      c.merge <<-EOF
        first   12
        second  first
      EOF
      assert_equal 12, c.second
    end
    
  end
end