require 'test/unit'
module Waw
  module Testing
    module Assertions
      include ::Test::Unit::Assertions
      
      # Checks if the last request was answered by a 404 not found
      def is404
        browser.is404
      end
      
    end # module Assertions
  end # module Testing
end # module Waw
