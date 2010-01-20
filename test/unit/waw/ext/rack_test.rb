require 'waw'
require 'test/unit'
module Waw
  class RackExtensionTest < Test::Unit::TestCase
    
    class AnApp
      include Rack::Delegator
      def initialize(name)
        @name = name
      end
      def to_s
        "#{self.class}('#{@name}')"
      end
    end
    
    # Creates a typical rack application under @app
    def setup
      @app1 = AnApp.new('/')
      @app2 = AnApp.new('/webserv/event')
      @app3 = AnApp.new('/webserv/people')
      @urlmap2 = ::Rack::URLMap.new(
        '/event' => @app2,
        '/people' => @app3 
      )
      @json = ::Waw::JSONController.new(@urlmap2)
      @urlmap1 = ::Rack::URLMap.new(
        '/' => @app1,
        '/webserv' => @json
      )
      @session = ::Rack::Session::Pool.new(@urlmap1, :domain => "www.waw.org", :expire_after => 65)
      @logger = ::Rack::CommonLogger.new(@session, STDOUT)
      @restart = ::Waw::Restart.new(@logger)
      @app = ::Waw::KernelApp.new(@restart)
    end
    
    def test_find_rack_app
      app = @app
      assert_equal @app1, app.find_rack_app('/')
      assert_equal @app1, app.find_rack_app('/'){|theapp| AnApp===theapp}
      assert ::Waw::JSONController===app.find_rack_app('/webserv')
      assert_equal @app2, app.find_rack_app('/webserv/event'){|theapp| AnApp===theapp}
      assert_equal @app2, app.find_rack_app('/webserv/event/and_an_action_name'){|theapp| AnApp===theapp}
      assert_equal @app3, app.find_rack_app('/webserv/people'){|theapp| AnApp===theapp}
      assert_equal @app3, app.find_rack_app('/webserv/people/and_an_action_name'){|theapp| AnApp===theapp}
      assert_equal @logger, app.find_rack_app{|theapp| ::Rack::CommonLogger===theapp}
      assert_equal @json, app.find_rack_app{|theapp| ::Waw::JSONController===theapp}
      
      Waw.kernel.app = app
      assert_equal @app1, Waw.find_rack_app('/')
      assert_equal @app1, Waw.find_rack_app('/'){|theapp| AnApp===theapp}
      assert ::Waw::JSONController===Waw.find_rack_app('/webserv')
      assert_equal @app2, Waw.find_rack_app('/webserv/event'){|theapp| AnApp===theapp}
      assert_equal @app2, Waw.find_rack_app('/webserv/event/and_an_action_name'){|theapp| AnApp===theapp}
      assert_equal @app3, Waw.find_rack_app('/webserv/people'){|theapp| AnApp===theapp}
      assert_equal @app3, Waw.find_rack_app('/webserv/people/and_an_action_name'){|theapp| AnApp===theapp}
      assert_equal @logger, Waw.find_rack_app{|theapp| ::Rack::CommonLogger===theapp}
      assert_equal @json, Waw.find_rack_app{|theapp| ::Waw::JSONController===theapp}
    end
    
    def test_find_url_of
      assert_equal '/', @app.find_url_of(@app)
      [@logger, @session, @urlmap1, @app1].each {|app| assert_equal '/', @app.find_url_of(app)}
      [@json, @urlmap2].each{|app| assert_equal '/webserv', @app.find_url_of(app)}
      [@app2].each{|app| assert_equal '/webserv/event', @app.find_url_of(app)}
      [@app3].each{|app| assert_equal '/webserv/people', @app.find_url_of(app)}
      assert_equal nil, @app.find_url_of(self)
    end
    
    def test_visit
      paths = Hash.new{|h,k| h[k] = []}
      @app.visit{|path, app| 
        paths[path] << app
      }
      expected = {
        '/' => [@app, @restart, @logger, @session, @urlmap1, @app1],
        '/webserv' => [@json, @urlmap2],
        '/webserv/event' => [@app2],
        '/webserv/people' => [@app3]
      }
      assert_equal expected, paths
    end
    
  end
end