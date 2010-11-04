module Waw
  class Crawler
    module Options
      
      # XPath queries for ping
      attr_accessor :ping_list
      
      # XPath queries for crawl
      attr_accessor :crawl_list
      
      # Checks links that lead outside the website?
      attr_accessor :check_externals
      
      # Listener to use
      attr_accessor :listener
      
      def set_default_options
        @ping_list = [
          'link/@href',
          'img/@src',
          'script/@src',
          'a/@href'
        ]
        @crawl_list = [
          'a/@href'
        ]
        @check_externals = false
        @listener = Crawler::Listener.new(STDOUT)
      end
      
      # Set/unset an XPath query to ping
      def ping_on(query, value = true)
        if value
          ping_list << query
        else
          ping_list.delete(query)
        end
      end
      
    end # module Options
  end # module Crawler
end # module Waw