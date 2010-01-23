require 'waw'
require 'waw/wspec'
require 'test/unit'
module Waw
  module WSpec
    class HTMLAnalysisTest < Test::Unit::TestCase
      include Waw::WSpec::HTMLAnalysis
      
      def browser_contents
        @contents ||= File.read(File.join(File.dirname(__FILE__), "html_analysis_test.html"))
      end
      
      def test_has_tag
        assert has_tag?("body")
        assert has_tag?("body", :class => "index")
        assert !has_tag?("body", :class => "another_class")
        assert !has_tag?("not_a_tag")
        assert has_tag?("div", :id => "footer")
        assert !has_tag?("div", :id => "footerare")
        assert has_tag?("form", :id => "newsletter_subscribe", :method => "post")
        assert has_tag?("form", :id => "newsletter_subscribe", :method => /(post|POST)/)
      end
      
    end
  end
end