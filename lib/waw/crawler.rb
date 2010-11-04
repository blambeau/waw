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
      until stack.empty?
        to_check = stack.shift
        case to_check
          when ::Mechanize::Page
            check_web_page(to_check)
          else
            logger.debug("Skipping verification of #{to_check.uri}: not recognized")
        end
      end
      @agent = nil
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
    
    # Converts an element for a location string
    def location_str_for(element)
      case element
        when String
          element
        when Mechanize::Page::Link
          element.href
        when Mechanize::Page::Image
          element.src
        when Nokogiri::XML::Element
          element[:href] || element[:src] || element[:url]
        else
          raise "Unexpected element #{element}"
      end
    end
    
    # Pings a single element
    def ping(element, referer_page)
      location = location_str_for(element)
      if location
        uri = resolve_uri(location, referer_page)
        unless already_checked_or_pending?(uri)
          agent.get(uri)
          checked[uri] = true
        else
          false
        end
      else
        nil
      end
    rescue => ex
      handle_error(ex, element)
    end
    
    def ping_web_page_uri(uri_href_src, page)
      if uri_href_src.nil? or uri_href_src.empty?
        nil
      else
        uri = resolve_uri(uri_href_src, page)
        unless already_checked_or_pending?(uri)
          agent.get(uri)
          checked[uri] = true
        else
          false
        end
      end
    end
    
    def check_web_page_link_href(page)
      page.search('link').each do |link|
        done = ping(link, page)
        if done
          logger.info("<link href='#{link[:href]}'> ok!")
        elsif done.nil?
          #logger.warn("<link #{link.inspect}> check failed")
        end
      end
    end
    
    def check_web_page_script_src(page)
      page.search('script').each do |script|
        done = ping(script, page)
        if done
          logger.info("<script src='#{script[:src]}'> ok!")
        elsif done.nil?
          #logger.warn("<script #{script.inspect}> check failed")
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
        done = ping(img, page)
        if done
          logger.info("<img src='#{img.src}'> ok!")
        elsif done.nil?
          #logger.warn("<script #{script.inspect}> check failed")
        end
      end
    end
    
    # Handles errors that occur
    def handle_error(ex, to_check)
      location = location_str_for(to_check)
      case ex
        when Mechanize::ResponseCodeError
          logger.error("lost link #{location}")
        when Mechanize::UnsupportedSchemeError
          logger.debug("unsupported scheme on #{location}")
        else
          raise ex
      end
    end
    
  end # class Crawler
end # module Waw 