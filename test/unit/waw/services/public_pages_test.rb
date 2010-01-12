require 'waw'
require 'waw/services/public_pages'
require 'test/unit'
module Waw
  module Services
    module PublicPages
      class ControllerTest < Test::Unit::TestCase
        include Waw::Services::PublicPages::Controller::Utils
    
        attr_reader :controller
    
        def setup
          here = File.dirname(__FILE__)
          public_pages = File.join(here, 'public', 'pages')
          @controller = Waw::Services::PublicPages::Controller.new(Waw::Services::PublicPages::Controller::DEFAULT_OPTIONS.merge(:templates_folder => public_pages, :pages_folder => public_pages))
        end
    
        def test_normalize_req_path
          assert_equal '/', normalize_req_path('')
          assert_equal '/', normalize_req_path('/')
          assert_equal '/', normalize_req_path('/index')
          assert_equal '/', normalize_req_path('/index.html')
          assert_equal '/', normalize_req_path('/index.htm')
          assert_equal '/latex', normalize_req_path('/latex')
          assert_equal '/latex', normalize_req_path('latex')
          assert_equal '/latex', normalize_req_path('latex.html')
          assert_equal '/latex', normalize_req_path('latex.htm')
          assert_equal '/latex', normalize_req_path('/latex.html')
          assert_equal '/latex', normalize_req_path('/latex.htm')
          assert_equal '/securite-vie-privee', normalize_req_path('/securite-vie-privee')
          assert_equal '/securite-vie-privee', normalize_req_path('/securite-vie-privee/')
          assert_equal '/securite-vie-privee', normalize_req_path('/securite-vie-privee/index')
          assert_equal '/securite-vie-privee', normalize_req_path('/securite-vie-privee/index.html')
          assert_equal '/securite-vie-privee', normalize_req_path('/securite-vie-privee/index.htm')
          assert_equal '/securite-vie-privee/sponsoring', normalize_req_path('/securite-vie-privee/sponsoring')
          assert_equal '/securite-vie-privee/sponsoring', normalize_req_path('/securite-vie-privee/sponsoring.html')
          assert_equal '/securite-vie-privee/sponsoring', normalize_req_path('/securite-vie-privee/sponsoring.htm')
          assert_equal '/securite-vie-privee/sponsoring', normalize_req_path('/securite-vie-privee/sponsoring/')
          assert_equal '/securite-vie-privee/sponsoring', normalize_req_path('   /securite-vie-privee/sponsoring/   ')
          assert_equal '/people/activate_account', normalize_req_path('/people/activate_account')
        end
      
        def test_relativize
          assert_equal 'file', relativize('/home/waw/public/pages/file', '/home/waw/public/pages/')
          assert_equal 'index.wtpl', relativize('public/pages/index.wtpl', 'public/pages')
        end
      
        def test_find_requested_page_file
          assert_equal 'index.wtpl', controller.find_requested_page_file('/')
          assert_equal 'index.wtpl', controller.find_requested_page_file('/index')
          assert_equal 'subfolder/index.wtpl', controller.find_requested_page_file('/subfolder')
          assert_equal 'subfolder/index.wtpl', controller.find_requested_page_file('/subfolder/index')
          assert_equal 'subfolder/hello.wtpl', controller.find_requested_page_file('/subfolder/hello')
          assert_nil controller.find_requested_page_file('/notexists')
          assert_nil controller.find_requested_page_file('/subfolder/notexists')
        end
      
        def test_controller_execution
          req = Object.new
          def req.set_path(path) @path = path end
          def req.path() @path end

          # on index
          %w{/ /index /index.html /index.htm}.each do |thepath|
            req.set_path(thepath)
            result = controller.execute(nil, req, nil)
            status, content_type, contents = result
            assert_equal 200, status
            assert_equal ['index'], contents
          end
        
          # on subfolder
          %w{/subfolder /subfolder/index.html}.each do |thepath|
            req.set_path(thepath)
            result = controller.execute(nil, req, nil)
            status, content_type, contents = result
            assert_equal 200, status
            assert_equal ['subfolder/index'], contents
          end
        
          # on subfolder/hello
          %w{/subfolder/hello /subfolder/hello.html}.each do |thepath|
            req.set_path(thepath)
            result = controller.execute(nil, req, nil)
            status, content_type, contents = result
            assert_equal 200, status
            assert_equal ['subfolder/hello'], contents
          end
        
          # on nonexists
          %w{/notexists /subfolder/notexists}.each do |thepath|
            req.set_path(thepath)
            result = controller.execute(nil, req, nil)
            status, content_type, contents = result
            assert_equal 404, status
          end
        
        end
      end
    end
  end
end
    
