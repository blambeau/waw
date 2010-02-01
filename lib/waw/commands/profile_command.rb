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
          puts "Visiting #{location}"
          browser.all_internal_links.each do |link|
            visit(browser, link[:href], visited)
          end
        end 
      end
      
      # Runs the sub-class defined command
      def __run(requester_file, arguments)
        require 'waw/wspec/browser'
        thread = ::Waw::Commands::StartCommand.new.waw_start(requester_file)
        visited, browser, location = {}, ::Waw::WSpec::Browser.new, Waw.config.web_base
        visit(browser, location, visited)
        thread.exit
      rescue Interrupt => ex
        info "waw-profile stopping now... ciao!"
      end

    end # module ProfileCommand
  end # module Commands
end # module Waw