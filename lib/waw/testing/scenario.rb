module Waw
  module Testing
    class Scenario
      include Assertions
      include HTMLAnalysis
      
      # Creates a scenario instance
      def initialize(&block)
        @browser = Browser.new
        self.instance_eval &block if block
      end
      
      # Sets the current location
      def location=(location)
        @browser.location = location
      end
      
    end # class Scenario
  end # module Testing
end # module Waw
