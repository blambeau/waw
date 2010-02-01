require 'waw/wspec'
require 'waw/commands/start_command'
module Waw
  module Commands
    class ProfileCommand < Command
      
      def banner
        <<-EOF
          Usage: [waw-]profile [options]
        EOF
      end
      
      # Start command is always safe
      def check_command_policy
        true
      end
      
      # Ignores a given location?
      def ignore?(location, visited)
        visited[location] or /\.(gif|zip|pdf|jpg|csv)$/ =~ location
      end
      
      # Recursively visits the whole website
      def visit(browser, location, visited = {})
        return if ignore?(location, visited)
        visited[location] = true
        browser.location = location
        unless browser.is200
          puts "Hohoho, I've found a lost internal link #{location}"
          return
        else
          puts "Visiting #{location}" if verbose
          browser.all_internal_links.each do |link|
            visit(browser, link[:href], visited)
          end
        end 
      end
      
      # Runs the sub-class defined command
      def __run(requester_file, arguments)
        require 'waw/wspec/browser'
        
        # Start the server first
        thread = ::Waw::Commands::StartCommand.new.waw_start(requester_file, verbose)
        visited, browser, location = {}, ::Waw::WSpec::Browser.new, Waw.config.web_base
        
        # Launch the visit
        t1 = Time.now
        visit(browser, location, visited)
        t2 = Time.now
        
        # Stop the server now
        thread.exit
        
        # Show statistics
        req_by_sec = visited.size.to_f/(t2-t1)
        avg_by_sec = (t2-t1)/visited.size
        
        puts "#{visited.size} pages visited in #{t2-t1} seconds (#{req_by_sec} req./sec., #{avg_by_sec} sec./req.)"
      rescue Interrupt => ex
        info "waw-profile stopping now... ciao!" if verbose
      end

    end # module ProfileCommand
  end # module Commands
end # module Waw