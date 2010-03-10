module Waw
  module Kern
    #
    # Provides the hook support to the waw kernel. 
    #
    # This module installs a @hooks instance variable (array of hooks by 
    # abstract name). It also expects the _root_folder_ and _logger_ instance 
    # variables provided by other modules.
    #
    module Hooks
      
      # Returns installed hooks for a given abstract name _which_ (:load, 
      # :start, :unload,...). This method always returns an array, which 
      # can be empty if no hook is currently installed under _which_.
      def hooks(which)
        @hooks = Hash.new{|h,k| h[k] = []} if @hooks.nil?
        @hooks[which]
      end
    
      # Adds a start hook.
      def add_start_hook(hook = nil, &block)
        hooks(:start) << (hook || block)
      end
    
      # Adds an unload hook.
      def add_unload_hook(hook = nil, &block)
        hooks(:unload) << (hook || block)
      end
    
      # Executes all hooks installed under _which_. Hooks installed through
      # the API are executed first. Hooks installed under root_folder/hooks/_which_
      # are executed then.
      def execute_hooks(which)
        # API installed hooks
        hooks(which).each do |hook|
          if hook.respond_to?(:run)
            hook.run(self)
          elsif hook.respond_to?(:call)
            hook.call(self)
          end
        end
        
        # the file ones now
        hooks_dir = File.join(root_folder, 'hooks', which.to_s)
        Dir[File.join(hooks_dir, '*.rb')].sort{|f1, f2| File.basename(f1) <=> File.basename(f2)}.each do |file|
          logger.info("Running waw #{which} hook #{file}...")
          ::Kernel.load(file)
        end
      end
      
    end # module Hooks
  end # module Kern
end # module Waw