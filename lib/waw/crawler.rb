require 'mechanize'
require 'waw/crawler/crawler_options'
module Waw
  class Crawler
    include Crawler::Options
  
    # Root URI to crawl
    attr_reader :root_uri
      
    # Mechanize agent instance
    attr_reader :agent
    
    # Stack of pages to visit
    attr_reader :stack
    
    # Pages checked
    attr_reader :checked
    
    # Creates a crawler instance on a root URI  
    def initialize(root_uri = nil)
      self.root_uri = root_uri
      set_default_options
    end
    
    # Sets the root uri
    def root_uri=(uri)
      @root_uri = if uri.nil?
        "127.0.0.1:9292"
      else
        uri.is_a?(URI) ? uri : URI::parse(uri.to_s)
      end
    end
    
    # Returns true if a given uri has already been checked or is currently
    # pending
    def already_checked_or_pending?(uri)
      checked[uri] || stack.find{|page| page.uri == uri}
    end
    
    # Returns true if a given page is internal to the website currently
    # crawled
    def internal_uri?(uri)
      uri.host.nil? or ((uri.host == root_uri.host) and (uri.port == root_uri.port))
    end
    
    # Returns true if a given page is internal to the website currently
    # crawled
    def internal_page?(page)
      internal_uri?(page.uri)
    end
    
    # Resolves as an absolute URI something that has been found on
    # a page
    def resolve_uri(href_or_src, page)
      URI::parse(agent.send(:resolve, href_or_src, page))
    end
    
    # Starts the crawling
    def crawl
      @agent = Mechanize.new
      @checked  = Hash.new
      @stack = [ agent.get(root_uri) ]
      _crawl
      @agent = nil
    end
    
    # Crawls the pages
    def _crawl
      until stack.empty?
        to_check = stack.shift
        case to_check
          when ::Mechanize::Page
            check_web_page(to_check)
          else
            logger.debug("Skipping verification of #{to_check.uri}: not recognized")
        end
      end
    end
    
    # Checks a web page
    def check_web_page(page)
      checked[page.uri] = true
      if internal_page?(page)
        logger.info("starting check of #{page.uri}")
        check_web_page_link_href(page) if check_link_href
        check_web_page_a_href(page) if check_a_href
        check_web_page_img_src(page) if check_img_src
        check_web_page_script_src(page) if check_script_src
      else
        logger.debug("no recursion on #{page.uri}")
      end
    end
    
    def check_web_page_link_href(page)
      page.search('link').each do |link|
        begin
          next if link[:href].nil? or link[:href].empty?
          uri = resolve_uri(link[:href], page)
          
          unless already_checked_or_pending?(uri)
            agent.get(uri)
            logger.info("pinging link #{uri}")
            checked[uri] = true
          end
        rescue => ex
          handle_error(ex, img)
        end
      end
    end
    
    def check_web_page_script_src(page)
      page.search('script').each do |link|
        begin
          next if link[:src].nil? or link[:src].empty?
          uri = resolve_uri(link[:src], page)
          
          unless already_checked_or_pending?(uri)
            agent.get(uri)
            logger.info("pinging script #{uri}")
            checked[uri] = true
          end
        rescue => ex
          handle_error(ex, img)
        end
      end
    end
    
    # Checks web page <a href="..."> 
    def check_web_page_a_href(page)
      page.links.each do |link|
        begin
        
          # bypass missing href
          next if link.href.nil? or link.href.empty?
        
          # the link as an absolute uri
          link_uri = resolve_uri(link.uri, page)
        
          # bypass links that lead to (to be) seen pages
          next if already_checked_or_pending?(link_uri)
        
          # make the click
          if internal_uri?(link_uri)
            stack.push(link.click)
            logger.debug("crawling on #{link_uri}")
          elsif check_externals
            stack.push(link.click)
            logger.info("pinging external #{link_uri}")
          else
            logger.debug("skipping external check of #{link_uri}")
          end
          
        rescue => ex
          handle_error(ex, link)
        end
      end
    end
    
    def check_web_page_img_src(page)
      page.images.each do |img|
        begin
          next if img.src.nil? or img.src.empty?
          uri = resolve_uri(img.src, page)
          
          unless already_checked_or_pending?(uri)
            agent.get(uri)
            logger.info("pinging image #{uri}")
            checked[uri] = true
          end
        rescue => ex
          handle_error(ex, img)
        end
      end
    end
    
    # Handles errors that occur
    def handle_error(ex, to_check)
      what = case to_check
        when Mechanize::Page
          to_check.uri
        when Mechanize::Page::Link
          to_check.href 
        when Mechanize::Page::Image
          to_check.src 
      end
      case ex
        when Mechanize::ResponseCodeError
          logger.error("lost link #{what}")
        when Mechanize::UnsupportedSchemeError
          logger.debug("unsupported scheme on #{what}")
        else
          raise ex
      end
    end
    
  end # class Crawler
end # module Waw 