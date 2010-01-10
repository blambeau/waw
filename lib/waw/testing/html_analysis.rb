module Waw
  module Testing
    #
    # Provides utility methods for analysis of XML/HTML contents.
    #
    # This module expects an accessor to a browser instance. Otherwise,
    # the browser_contents method may be overrided.
    #
    module HTMLAnalysis

      # Yields the block passing browser contents as first argument
      def browser_contents
        browser.contents
      end

      # Look for some html tag
      def has_tag?(name, opts = nil, contents = browser_contents, treat_values_as_regexp = true)
        # check that the tag exists
        contents.scan(/(<\s*#{name}\s*(.*?)\/?>)/) do |match|
          return match[0] if opts.nil? or opts.empty?
          
          # check tag attributes now
          attributes = match[1]
          found = {}
          opts.each_pair do |k, v|
            krx = Regexp.escape(k.to_s)
            vrx = treat_values_as_regexp ? v : Regexp.escape(v.to_s)
            rgxp = v.nil? ?
                   Regexp.compile(/#{k}\s*=\s*["']([^"']*)["']/) :
                   Regexp.compile(/#{k}\s*=\s*["'](#{v})["']/)
            if rgxp =~ attributes 
              found[k] = $1
            else
              found = nil
              break
            end
          end
          
          return found unless found.nil?
        end
        nil
      end

      # Assert that the user sees something in the browser contents
      def i_see?(what, contents = browser_contents)
        not(contents.nil?) and not(contents.index(what).nil?)
      end
      
    end # module HTMLAnalysis
  end # module Testing
end # module Waw