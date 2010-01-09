module Waw
  # Implements waw configuration utility
  class Config
    
    # Implementation of the config domain specific language
    class DSL
      
      # Creates a DSL instance
      def initialize(config)
        @config = config
      end
      
      # When a method is missing, install config parameter
      def method_missing(name, *args)
        @config.install_configuration_property(name, args.size==1 ? args[0] : args)
      end
      
    end # class DSL
    
    # Initialize a configuration instance. If merge_default is set to true,
    # the default configuration file is automatically loaded.
    def initialize(merge_default = true)
      self.merge(File.join(File.dirname(__FILE__), 'default_config.cfg')) if merge_default
    end
    
    # Raises a configuration error
    def config_error(name, message)
      raise ConfigurationError, message
    end
    
    # Installs a configuration parameter
    def install_configuration_property(name, value)
      case name
        when :log_dir
          config_error(name, "log_dir is expected to be a string") unless String===value
          config_error(name, "Unable to access log_dir #{value}") unless File.exists?(value) and 
                                                                         File.directory?(value) and
                                                                         File.writable?(value)
        when :log_file
          config_error(name, "log_file is expected to be a string") unless String===value
        when :log_level
          config_error(name, "Bad log_level #{value}") unless value>=0 and value<=5
        when :log_frequency
          config_error(name, "Bad log_frequency #{value}") unless %w{daily weekly monthly}.include?(value)
        when :web_domain, :web_base
          config_error(name, "web_domain is expected to be a string") unless String===value
        when :rack_session
          config_error(name, "rack_session is expected to be true or false") unless true==value or false==value
        when :rack_session_expire
          config_error(name, "rack_session_expire is expected to be an Integer") unless Integer===value
        when :waw_services
          value = [value] unless Array===value
          config_error(name, "Unrecognized waw services #{value}") unless check_services(value)
      end
      instance_eval "@#{name} = value"
      instance_eval <<-EOF
        def #{name}(force_array = false)
          value = @#{name}
          force_array ? (Array===value ? value : [value]) : value
        end
      EOF
    end
    
    # Checks waw services
    def check_services(services)
      services.all?{|m| Module===m}
    end
    
    # Merges the configuration with a given configuration file
    def merge(config_file)
      raise ArgumentError, "Config file does not exists" unless File.exists?(config_file)
      begin
        DSL.new(self).instance_eval File.read(config_file)
      rescue ConfigurationError => ex
        raise ex
      end
      self
    end
    
  end # class Config
end # module Waw