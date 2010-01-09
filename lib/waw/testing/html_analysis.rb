module Waw
  module Testing
    module HTMLAnalysis

      # Assert that the user sees something in the browser contents
      def i_see(what)
        contents = browser.contents
        not(contents.nil?) and not(contents.index(what).nil?)
      end
      

    end # module HTMLAnalysis
  end # module Testing
end # module Waw