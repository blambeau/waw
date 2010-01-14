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
    
    def test_config_allows_block
      c = Config.new(false)
      c.merge <<-EOF
        help           12
        jsgeneration   { true }
      EOF
      assert_equal 12, c.help
      assert_equal true, c.jsgeneration
    end

    def test_config_allows_block_referencing_others
      c = Config.new(false)
      c.merge <<-EOF
        mode           'devel'
        jsgeneration   { mode=='devel' }
        sendmails      { mode=='production' }
      EOF
      assert_equal 'devel', c.mode
      assert_equal true, c.jsgeneration
      assert_equal false, c.sendmails
    end
    
  end
end