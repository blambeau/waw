require 'waw/wspec/html_analysis/tag'
module Waw
  module WSpec
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
      
      # Decodes a string of HTML attributes as a hash with symbols as keys
      def decode_attributes_string(str)
        attrs = {}
        str.scan(/([a-z]+)=["'](.*?)["']/) do |match|
          attrs[match[0].to_sym] = match[1]
        end
        attrs
      end
      
      #################################################################### Tag helpers
      
      # Find tags inside the browser contents. If a block is given, yield it with
      # each tag information. Otherwise, returns an array of found tags, that can be
      # empty.
      def tags(name, opts = nil, contents = browser_contents)
        found = [] unless block_given?
        contents.scan(/(<\s*#{name}\s*(.*?)\/?>)/) do |match|
          tag = Tag.new(match[0], name, decode_attributes_string(match[1]))
          next unless tag.matches?(opts)
          block_given? ? yield(tag) : (found << tag)
        end
        found
      end
      
      # Iterates over a tag specification
      def each_tag(name, opts = nil, contents = browser_contents, &block)
        tags(name, opts, contents, &block)
      end
      
      # Shortcut for <code>tags(name, opts, contents)[0]</code>. Returns nil if no such 
      # tag can be found
      def first_tag(name, opts = nil, contents = browser_contents)
        tags(name, opts, contents)[0]
      end
      alias :tag :first_tag

      # Look for some html tag
      def has_tag?(name, opts = nil, contents = browser_contents)
        return tags(name, opts, contents).size != 0
      end

      #################################################################### Links helpers
      
      # Shortcut for <code>tags('a', {:href => /^(.*?)$/}.merge(opts), contents, &block)</code>
      def all_links(opts = nil, contents = browser_contents, &block)
        tags('a', {:href => /^(.*?)$/}.merge(opts || {}), contents, &block)
      end
      alias :links :all_links
      
      # Same as all_links, but retains internal links only (i.e. <code>not(URI::Generic.absolute?)</code>)
      def all_internal_links(opts = nil, contents = browser_contents, &block)
        if block
          all_links(opts, contents).each do |link|
            yield(link) unless URI.parse(link[:href]).absolute?
          end
        else
          all_links(opts, contents).reject{|link| URI.parse(link[:href]).absolute?}
        end
      end
      alias :internal_links :all_internal_links
      
      # Same as all_links, but retains external links only (i.e. <code>URI::Generic.absolute?</code>)
      def all_external_links(opts = nil, contents = browser_contents, &block)
        if block
          all_links(opts, contents).each do |link|
            yield(link) if URI.parse(link[:href]).absolute?
          end
        else
          all_links(opts, contents).select{|link| URI.parse(link[:href]).absolute?}
        end
      end 
      alias :external_links :all_external_links
      
      # Assert that the user sees something in the browser contents
      def i_see?(what, contents = browser_contents)
        not(contents.nil?) and not(contents.index(what).nil?)
      end
      
    end # module HTMLAnalysis
  end # module WSpec
end # module Waw