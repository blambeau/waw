require 'waw/crawler'
module Waw
  module Commands
    class CrawlCommand < Command
      
      def banner
        <<-EOF
          Usage: waw-crawl [options] WEB_SITE_URI
        EOF
      end
      
      # Start command is always safe
      def check_command_policy
        true
      end
      
      # Adds the options
      def add_options(options)
        @crawler = Waw::Crawler.new(nil)
        options.on("--[no-]check-externals", "[Don't] ping any external link") do |value|
          @crawler.check_externals = value
        end
        options.on("--[no-]check-img", "[Don't] check image <img src='...'>") do |value|
          @crawler.ping_on('img/@src', value)
        end
        options.on("--[no-]check-link", "[Don't] check <link href='...'>") do |value|
          @crawler.ping_on('link/@href', value)
        end
        options.on("--[no-]check-script", "[Don't] check <script src='...'>") do |value|
          @crawler.ping_on('script/@src', value)
        end
      end
      
      # Runs the sub-class defined command
      def __run(requester_file, arguments)
        exit(nil, true) unless (arguments.size == 1)
        @crawler.root_uri = arguments[0]
        @crawler.listener.verbosity = @verbosity
        @crawler.crawl
      rescue Interrupt => ex
        info "waw-crawl stopping now... ciao!" if verbose
      end

    end # module ProfileCommand
  end # module Commands
end # module Waw