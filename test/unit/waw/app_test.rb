require 'fileutils'
require 'test/unit'
require 'waw'
module Waw
  class AppTest < Test::Unit::TestCase
    include Waw::App
    
    def self.app
      @app
    end
    
    def self.app=(app)
      @app = app
    end
    
    attr_reader :folder
    
    def setup
      @folder = File.join(File.dirname(__FILE__), 'app_test')
    end

    def teardown
      FileUtils.rm_rf File.join('logs')
      FileUtils.rm_rf File.join(@folder, 'wawdeploy')
      FileUtils.rm_rf File.join(@folder, 'waw.deploy')
      FileUtils.rm_rf File.join(@folder, 'waw.routing')
      FileUtils.rm_rf File.join(@folder, 'waw.commons.routing')
      FileUtils.rm_rf File.join(@folder, 'waw.devel.routing')
    end
    
    def wawdeploy(words, old=false)
      File.open(File.join(@folder, old ? "wawdeploy" : "waw.deploy"), 'w') do |io|
        io << "# It supports comments\n"
        io << words.join(' ') << "\n"
        io << "# And here too\n"
      end
      yield
    end
    
    def wawrouting(name, value)
      file = name ? "waw.#{name}.routing" : "waw.routing"
      File.open(File.join(@folder, file), 'w') do |io|
        io << "Waw::AppTest.app = '#{value}'"
      end
    end
    
    def test_it_supports_empty_config
      assert_nothing_raised do
        wawdeploy %w{} do
          load_application(folder)
        end
      end
    end
    
    def test_it_load_config_in_good_order
      wawdeploy %w{commons devel} do
        load_application(folder)
        assert_equal 2, config.test_value
        assert_equal %w{commons devel}, deploy_words
      end
      wawdeploy %w{devel commons} do
        load_application(folder)
        assert_equal 1, config.test_value
        assert_equal %w{devel commons}, deploy_words
      end
    end
    
    def test_it_supports_old_wawdeploy
      wawdeploy %w{commons devel}, true do
        load_application(folder)
        assert_equal 2, config.test_value
        assert_equal %w{commons devel}, deploy_words
      end
    end
    
    def test_it_loads_correct_routing
      wawdeploy %w{commons devel} do
        wawrouting nil, "This is the standard routing"
        wawrouting "commons", "This is the commons routing"
        wawrouting "devel", "This is the devel routing"
        load_application(folder)
        assert_equal "This is the devel routing", Waw::AppTest.app
      end
    end

    def test_it_loads_correct_routing_2
      wawdeploy %w{commons devel} do
        wawrouting nil, "This is the standard routing"
        wawrouting "commons", "This is the commons routing"
        load_application(folder)
        assert_equal "This is the commons routing", Waw::AppTest.app
      end
    end

    def test_it_loads_correct_routing_3
      wawdeploy %w{devel} do
        wawrouting nil, "This is the standard routing"
        wawrouting "commons", "This is the commons routing"
        load_application(folder)
        assert_equal "This is the standard routing", Waw::AppTest.app
      end
    end
    
    def test_it_loads_correct_routing_4
      wawdeploy %w{} do
        wawrouting nil, "This is the standard routing"
        wawrouting "commons", "This is the commons routing"
        wawrouting "devel", "This is the commons routing"
        load_application(folder)
        assert_equal "This is the standard routing", Waw::AppTest.app
      end
    end
    
    def test_it_loads_correct_routing_4
      wawdeploy %w{devel commons} do
        wawrouting nil, "This is the standard routing"
        wawrouting "commons", "This is the commons routing"
        wawrouting "devel", "This is the commons routing"
        load_application(folder)
        assert_equal "This is the commons routing", Waw::AppTest.app
      end
    end
    
  end
end