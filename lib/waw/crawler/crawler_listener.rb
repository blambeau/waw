require 'highline'
module Waw
  class Crawler
    class Listener
      
      attr_reader :highline
      attr_accessor :verbosity
      
      # Creates a listener instance
      def initialize(output)
        @highline = HighLine.new(STDIN, output)
        @verbosity = 1
      end
      
      def checking(page, &block)
        if verbosity > 0
          highline.say page.uri.to_s
        end
        block.call
      end
      
      def doc_skipped(to_check)
        if verbosity > 1
          highline.say highline.color(to_check.uri, :magenta)
        end
      end
      
      def crawl_skipped(referer_page, location)
        if verbosity > 1
          highline.say '  + crawling skipped: ' + highline.color(location, :magenta)
        end
      end
      
      def ping_ok(referer_page, location)
        if verbosity > 1
          highline.say '  + ping ok: ' + highline.color(location, :green)
        end
      end

      def ping_skipped(referer_page, location)
        if verbosity > 1
          highline.say '  + ping skipped: ' + highline.color(location, :magenta)
        end
      end
      
      def reach_failure(referer_page, location, ex)
        highline.say '  + reach failure: ' + highline.color(location, :red)
      end
      
      def scheme_failure(referer_page, location, ex)
        if verbosity > 1
          highline.say '  + scheme failure: ' + highline.color(location, :magenta)
        end
      end
      
      def socket_error(referer_page, location, ex)
        if verbosity > 1
          highline.say '  + socket failure: ' + highline.color(location, :magenta)
        end
      end
      
    end # class Listener
  end # module Crawler
end # module Waw