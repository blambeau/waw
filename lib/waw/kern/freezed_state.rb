module Waw
  module Kern
    # 
    # Contains all attribute accessors for what is considered freezed 
    # after application loading.
    #
    module FreezedState
      
      # Root application folder
      attr_accessor :root_folder
      
      # Deploy words found in waw.deploy
      attr_accessor :deploy_words
      
      # ::Waw::Config instance
      attr_accessor :config
      
      # Logger instance
      attr_accessor :logger
      
      # ::Waw::ResourceCollection instance
      attr_accessor :resources
      
      # Routing name
      attr_accessor :routing
      
      # Rack user's application
      attr_accessor :app
      
    end # module FreezedState
  end # module Kern
end # module Waw