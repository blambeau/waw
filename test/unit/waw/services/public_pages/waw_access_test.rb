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
            serve '.wtpl' do |url, page, app|
              {:message => 'serving .wtpl'}
            end
          end
        EOF
        
        SECOND_WAW_ACCESS = <<-EOF
          wawaccess do 
            serve '.html' do |url, page, app|
              {:message => 'serving .html'}
            end
            serve '.brick' do |url, page, app|
              {:message => 'serving .brick'}
            end
          end
        EOF
        
        def test_dsl_on_first_waw_access
          assert_nothing_raised do 
            wawaccess = WawAccess.new.dsl_merge(FIRST_WAW_ACCESS)
            assert_equal :allow_all, wawaccess.strategy
            assert wawaccess.may_serve?('test.wtpl')
            assert !wawaccess.may_serve?('test.brick')
            assert_equal 'serving .wtpl', wawaccess.prepare_serve('/test', 'test.wtpl')[:message]
          end
        end
        
        def test_dsl_on_second_waw_access
          assert_nothing_raised do 
            wawaccess = WawAccess.new.dsl_merge(SECOND_WAW_ACCESS)
            assert_equal :deny_all, wawaccess.strategy
            assert !wawaccess.may_serve?('test.wtpl')
            assert wawaccess.may_serve?('test.html')
            assert wawaccess.may_serve?('test.brick')
            assert_equal 'serving .html', wawaccess.prepare_serve('/test', 'test.html')[:message]
            assert_equal 'serving .brick', wawaccess.prepare_serve('/test', 'test.brick')[:message]
          end
        end
        
        def test_wawaccess_hierarchy
          first = WawAccess.new.dsl_merge(FIRST_WAW_ACCESS)
          second = WawAccess.new.dsl_merge(SECOND_WAW_ACCESS)
          assert !second.may_serve?('test.wtpl')
          second.parent = first
          assert_equal true, second.may_serve?('test.wtpl', true)
          assert_equal 'serving .wtpl', second.prepare_serve('/test', 'test.wtpl')[:message]
        end
        
        def assert_successfull_serve(what, content_type=nil, msg = "#{what} is sucessfully served")
          status, headers, value = what
          contenttype = headers['Content-Type']
          assert_equal(200, status, msg)
          assert_equal(content_type, contenttype, msg) if content_type
        end
        
        def test_on_example
          wawaccess = WawAccess.load_hierarchy(File.join(File.dirname(__FILE__), 'example'))
          assert WawAccess===wawaccess
          assert_successfull_serve wawaccess.serve('/css/example.css'), 'text/plain'
          assert_successfull_serve wawaccess.serve('/pages/hello.wtpl'), 'text/html'
          assert_successfull_serve wawaccess.serve('/hello.wtpl'), 'text/html'
        end
        
      end
    end
  end
end
