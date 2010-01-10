require 'json'
module Waw
  module Testing
    class Scenario
      include Assertions
      include HTMLAnalysis
      
      # The browser instance underlying this scenario
      attr_reader :browser
      
      # Number of assertions done
      attr_reader :assertion_count
      
      # Creates a scenario instance
      def initialize(&block)
        @browser = Browser.new
        @block = block
        @assertion_count = 0
      end
      
      # Sets the current location
      def location(location)
        @browser.location = location
      end
      alias :go :location
      
      # Follow some tag (typically a <a href="..."> or a <form action="...">)
      def follow(tag, attributes)
        assert_not_nil(found = has_tag?(tag, attributes), "tag #{tag}, #{attributes.inspect} can be found for follow")
        case tag
          when 'a', :a
            browser.click_href(found[:href])
          else
            raise ArgumentError, "Unexpected tag type #{tag} for follow"
        end
      end
      
      # Adds an assertion
      def add_assertion
        @assertion_count += 1
      end
      
      # Run the test scenario
      def run
        self.instance_eval &@block
      end
      
    end # class Scenario
  end # module Testing
end # module Waw
