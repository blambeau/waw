require 'mechanize'
require 'waw/crawler/crawler_options'
require 'waw/crawler/crawler_listener'
module Waw
  class Crawler
    include Crawler::Options
    
    ###################################################################### Internal state
    
    # Mechanize agent instance
    attr_reader :agent
    
    # Root URI to crawl
    attr_reader :root_uri
      
    # Sets the root uri
    def root_uri=(uri)
      @root_uri = if uri.nil?
        "127.0.0.1:9292"
      else
        uri.is_a?(URI) ? uri : URI::parse(uri.to_s)
      end
    end
    
    # Stack of files/pages to visit
    attr_reader :stack
    
    ###################################################################### About URI visit state
    
    # URI statuses
    attr_reader :uristate
    
    # 
    PINGED   = 1
    PENDING  = 2
    CHECKING = 4
    CHECKED  = 8
    
    # Marks an URI as currently pending 
    def pending!(uri)
      uristate[uri] |= PENDING
    end

    # Marks an URI as being pinged 
    def pinged!(uri)
      uristate[uri] |= PINGED
    end

    ###################################################################### Initialization
    
    # Creates a crawler instance on a root URI  
    def initialize(root_uri = nil)
      self.root_uri = root_uri
      set_default_options
    end
    
    ###################################################################### Utils
    
    # Returns true if a given page is internal to the website currently
    # crawled
    def internal_uri?(uri)
      uri.host.nil? or ((uri.host == root_uri.host) and (uri.port == root_uri.port))
    end
    
    # Resolves as an absolute URI something that has been found on
    # a page
    def resolve_uri(href_or_src, page)
      URI::parse(agent.send(:resolve, href_or_src, page))
    end
    
    ###################################################################### Crawling
    
    # Starts the crawling
    def crawl
      @agent = Mechanize.new
      @uristate = Hash.new{|h,k| h[k] = 0}
      @stack = [ agent.get(root_uri) ]
      until stack.empty?
        to_check = stack.shift
        case to_check
          when ::Mechanize::Page
            check_web_page(to_check)
          else
            listener.doc_skipped(to_check)
        end
      end
      @agent = nil
      @uristate = nil
      @stack = nil
    end
    
    def crawl_all(query, referer_page)
      referer_page.search(query).each do |loc|
        crawl_one(loc, referer_page)
      end
    end
    
    def crawl_one(location, referer_page)
      uri = resolve_uri(location, referer_page)
      
      # Bypass PENDING/CHECKING/CHECKED links
      if uristate[uri] < PENDING
      
        # Mark it as PENDING now
        pending!(uri)

        # Mark as to crawl by pushing on the stack
        if internal_uri?(uri)
          stack.push(agent.get(uri))
        else
          listener.crawl_skipped(referer_page, location)
        end
        
      end
    rescue => ex
      handle_error(ex, referer_page, location)
    end
    
    ###################################################################### Checking
    
    def check_web_page(page)
      uristate[page.uri] |= CHECKING
      listener.checking(page){
        # Make ping checks
        all_ping!(ping_list.join(', '), page)
        # Crawl all links now
        crawl_all(crawl_list.join(', '), page)
      }
      uristate[page.uri] |= CHECKED
    end
    
    ###################################################################### Pinging
    
    def all_ping!(query, referer_page)
      referer_page.search(query).each do |loc|
        ping!(loc, referer_page)
      end
    end
    
    def ping!(loc, referer_page)
      uri = resolve_uri(loc, referer_page)
      
      # Only ping uri that are not PINGED/PENDING/CHECKING/CHECKED
      return unless uristate[uri] < PINGED

      # bypass externals if required
      if internal_uri?(uri) || check_externals
        agent.head(uri) # ping!
        pinged!(uri)
        listener.ping_ok(referer_page, loc)
      else
        listener.ping_skipped(referer_page, loc)
      end
      
    rescue => ex
      handle_error(ex, referer_page, loc)
    end
    
    ###################################################################### Error handling
    
    # Handles errors that occur
    def handle_error(ex, referer_page, loc)
      case ex
        when Mechanize::ResponseCodeError
          listener.reach_failure(referer_page, loc, ex)
        when Mechanize::UnsupportedSchemeError
          listener.scheme_failure(referer_page, loc, ex)
        when SocketError
          listener.socket_error(referer_page, loc, ex)
        else
          raise ex
      end
    end
    
  end # class Crawler
end # module Waw 