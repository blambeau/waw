require 'waw'
require 'test/unit'
module Waw
  class RackExtensionTest < Test::Unit::TestCase
    
    class AnApp
      include Rack::FindRackAppDelegator
      def initialize(name)
        @name = name
      end
      def to_s
        "#{self.class}('#{@name}')"
      end
    end
    APP_1 = AnApp.new('/')
    APP_2 = AnApp.new('/webserv/event')
    APP_3 = AnApp.new('/webserv/people')
    
    def test_find_rack_app
      app = Rack::Builder.new do
        use ::Rack::CommonLogger
        use ::Rack::Session::Pool, :domain       => "www.waw.org",
                                   :expire_after => 65
        map '/' do
          run RackExtensionTest::APP_1
        end
        map '/webserv' do
          use ::Waw::JSONController
          map '/event' do
            run RackExtensionTest::APP_2
          end
          map '/people' do
            run RackExtensionTest::APP_3
          end
        end
      end
      app = app.to_app
      
      assert_equal APP_1, app.find_rack_app('/')
      assert_equal APP_1, app.find_rack_app('/'){|theapp| AnApp===theapp}
      assert ::Waw::JSONController===app.find_rack_app('/webserv')
      assert_equal APP_2, app.find_rack_app('/webserv/event'){|theapp| AnApp===theapp}
      assert_equal APP_2, app.find_rack_app('/webserv/event/and_an_action_name'){|theapp| AnApp===theapp}
      assert_equal APP_3, app.find_rack_app('/webserv/people'){|theapp| AnApp===theapp}
      assert_equal APP_3, app.find_rack_app('/webserv/people/and_an_action_name'){|theapp| AnApp===theapp}
      
      Waw.app = app
      assert_equal APP_1, Waw.find_rack_app('/')
      assert_equal APP_1, Waw.find_rack_app('/'){|theapp| AnApp===theapp}
      assert ::Waw::JSONController===Waw.find_rack_app('/webserv')
      assert_equal APP_2, Waw.find_rack_app('/webserv/event'){|theapp| AnApp===theapp}
      assert_equal APP_2, Waw.find_rack_app('/webserv/event/and_an_action_name'){|theapp| AnApp===theapp}
      assert_equal APP_3, Waw.find_rack_app('/webserv/people'){|theapp| AnApp===theapp}
      assert_equal APP_3, Waw.find_rack_app('/webserv/people/and_an_action_name'){|theapp| AnApp===theapp}
    end
    
  end
end