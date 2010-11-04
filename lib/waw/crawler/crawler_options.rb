module Waw
  class Crawler
    module Options
      
      # Checks <link href='...'> ?
      attr_accessor :check_link_href

      # Checks <script src='...'>
      attr_accessor :check_script_src
      
      # Checks internal <a href='...'> ?
      attr_accessor :check_a_href
      
      # Checks <img src='...'> ?
      attr_accessor :check_img_src
      
      # Checks links that lead outside the website?
      attr_accessor :check_externals
      
      # Logger to use
      attr_accessor :logger
      
      def set_default_options
        @check_link_href = true
        @check_script_src = true
        @check_a_href = true
        @check_img_src = true
        @check_externals = false
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
      end
      
    end # module Options
  end # module Crawler
end # module Waw