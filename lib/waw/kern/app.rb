module Waw
  module Kern
    # Kernel waw application
    class App
      include ::Rack::Delegator
      include ::Waw::Kern::FreezedState
      include ::Waw::Kern::LivingState
      include ::Waw::Kern::Hooks
      include ::Waw::Kern::Utils
      include ::Waw::Kern::Lifecycle
      
      # Creates a kernel application instance
      def initialize(identifier = nil, options = {})
        @options = options
      end
    
      # Installs the environment and delegates to the business 
      # application
      def call(env)
        install_living_state(env)
        if app=self.app
          app.call(env)
        else
          [503, {'Content-Type' => 'text/plain'}, ['This waw application is unloaded']]
        end
      rescue ::WLang::Error => ex
        # On exception, returns a 500 with a message
        logger.error("Fatal error #{ex.message}")
        logger.error(ex.wlang_backtrace.join("\n"))
        logger.error(ex.backtrace.join("\n"))
        [500, {'Content-Type' => 'text/plain'}, ['500 Internal Server Error']]
      rescue Exception => ex
        # On exception, returns a 500 with a message
        logger.error("Fatal error #{ex.message}")
        logger.error(ex.backtrace.join("\n"))
        [500, {'Content-Type' => 'text/plain'}, ['500 Internal Server Error']]
      ensure
        clean_living_state
      end
      
      # Returns an identifier for this kernel application
      def identifier
        @identifier || "No identifier (#{root_folder}/#{routing})"
      end
    
    end # class App
  end # module Kern
end # module Waw