require 'test/unit'
require 'waw'
module Waw
  module Services
    module PublicPages
      # Waw version of .htaccess files
      class WawAccessTest < Test::Unit::TestCase
        
        FIRST_WAW_ACCESS = <<-EOF
          wawaccess do 
            strategy :allow_all
            match '.wtpl' do
              {:message => 'serving .wtpl'}
            end
          end
        EOF
        
        SECOND_WAW_ACCESS = <<-EOF
          wawaccess do 
            match '.html' do
              {:message => 'serving .html'}
            end
            match '.brick' do
              {:message => 'serving .brick'}
            end
          end
        EOF
        
        def test_dsl
          first = WawAccess.new.dsl_merge(FIRST_WAW_ACCESS)
          second = WawAccess.new.dsl_merge(SECOND_WAW_ACCESS)
          
          first.folder = "/home"
          second.folder = "/home/css"
          second.parent = first
          assert_nil first.parent
          assert_equal "", first.identifier(false)
          assert_equal ".wawaccess", first.identifier(true)
          assert_equal "css/.wawaccess", second.identifier
          assert_equal first, first.root
          assert_equal first, second.root
        end
        
        def test_find_wawaccess_for
          wawaccess = WawAccess.load_hierarchy(File.join(File.dirname(__FILE__), 'example'))
          assert_equal '.wawaccess', wawaccess.find_wawaccess_for('/').identifier
          assert_equal '.wawaccess', wawaccess.find_wawaccess_for('/index.html').identifier
          assert_equal '.wawaccess', wawaccess.find_wawaccess_for('/unexisting').identifier
          assert_equal 'css/.wawaccess', wawaccess.find_wawaccess_for('/css').identifier
          assert_equal 'css/.wawaccess', wawaccess.find_wawaccess_for('css').identifier
          assert_equal 'css/.wawaccess', wawaccess.find_wawaccess_for('/css/example.css').identifier
          assert_equal 'js/.wawaccess', wawaccess.find_wawaccess_for('/js/example.js').identifier
          assert_equal 'pages/.wawaccess', wawaccess.find_wawaccess_for('/pages').identifier
          assert_equal 'pages/.wawaccess', wawaccess.find_wawaccess_for('/pages/').identifier
          assert_equal 'pages/.wawaccess', wawaccess.find_wawaccess_for('/pages/hello.wtpl').identifier
        end
        
        def assert_successfull_serve(what, content=nil, msg = "#{what} is sucessfully served")
          status, headers, value = what
          value = value.join("\n") if Array===value
          contenttype = headers['Content-Type']
          assert_equal(200, status, msg)
          assert_equal(content, value) if content
        end
        
        def test_on_example
          wawaccess = WawAccess.load_hierarchy(File.join(File.dirname(__FILE__), 'example'))
          assert WawAccess===wawaccess
          # assert_successfull_serve wawaccess.do_path_serve('/css/example.css'), "/* example.css */"
          assert_successfull_serve wawaccess.do_path_serve('/'), "Hello blambeau"
          # assert_successfull_serve wawaccess.do_path_serve('/hello.wtpl'), "Hello blambeau"
          # assert_successfull_serve wawaccess.do_path_serve('/pages/hello.wtpl'), "Hello blambeau"
        end
        
      end
    end
  end
end
