module Waw
  module Commands
    class StartCommand < Command
      
      def banner
        <<-EOF
          Usage: [waw-]start [options]
        EOF
      end
      
      # Start command is always safe
      def check_command_policy
        true
      end
      
      # Executes the waw-start command and returns the running thread
      def waw_start(requester_file, verbose = true)
        waw_kernel = Waw.autoload(requester_file)
        t = Thread.new(waw_kernel) do |app|
          begin
            server = Rack::Handler::Mongrel
          rescue LoadError => e
            server = Rack::Handler::WEBrick
          end
          options = {:Port => app.config.web_port, :Host => "0.0.0.0", :AccessLog => []}
          server.run app, options
        end
        try, ok = 0, false
        begin
          info "Attempting to reach the web server..." if verbose
          Net::HTTP.get(URI.parse(waw_kernel.config.web_base))
          ok = true
        rescue Errno::ECONNREFUSED => ex
          sleep 0.1
        end until (ok or (try += 1)>10)
        if ok
          if verbose
            info "Your web application has been started successfully"
            info "Have a look at #{waw_kernel.config.web_base}"
            info "Enjoy waw!"
          end
          [t, waw_kernel]
        else
          raise Waw::Error, "Unable to reach the web server after having been started"
        end
      end
      
      # Runs the sub-class defined command
      def __run(requester_file, arguments)
        waw_start(requester_file)[0].join
      rescue Interrupt => ex
        info "waw-start stopping now... ciao!"
      end

    end # class StartCommand
  end # module Commans
end # module Waw