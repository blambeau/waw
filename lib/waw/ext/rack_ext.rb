# Force some auto loading ...
require 'rubygems'
require 'rack'
::Rack::Session::Pool
module Rack
  
  # Extends Rack application with utilities. This module may be included
  # by standard rack applications delegating to another one. The later is
  # expected to be returned by delegate. Methods are intended to be 
  # overriden for matching specific situations.
  module FindRackAppDelegator

    # Returns delegate rack application. By default, returns @app.
    def delegate
      @app
    end
    
    # Checks if an app may be safely considered in the chain
    def is_delegate?(app)
      FindRackAppDelegator===app
    end
    
    # Checks if a delegate exists.
    def has_delegate?
      not(delegate.nil?) and is_delegate?(delegate)
    end

    # Finds a rack application mapped to a given path. If a block is 
    # provided it is used as a predicate matcher.
    def find_rack_app(path = nil, &block)
      return self if (block && block.call(self))
      has_delegate? ? delegate.find_rack_app(path, &block) : nil
    end
    
    # Recursively finds the URL on which a given application is installed.
    def find_url_of(app)
      visit{|path, visited| return path if app==visited}
    end
    
    # Visits the Rack application tree recursively by calling the block.
    # The later is expected to have two parameters |path,app|. The first
    # one is an array containing url components, the second is the 
    # visited application.
    def visit(&block)
      _visit("/", block)
    end
    
    # Internal implementation of visit.
    def _visit(path, block)
      block.call(path, self)
      delegate._visit(path, block) if has_delegate?
    end
    
  end # module FindRackAppDelegator
  
  # Install the delegator on all standard Rack applications
  [::Rack::Builder, ::Rack::Session::Abstract::ID, ::Rack::CommonLogger,
   ::Rack::ShowExceptions, ::Rack::Static, ::Rack::URLMap, ::Rack::Reloader].each do |rack_app|
     rack_app.instance_eval <<-EOF
       include FindRackAppDelegator
     EOF
   end
  
  # Some overridings of FindRackAppDelegator
  class URLMap
    
    # Overrides FindRackAppDelegator.find_rack_app
    def find_rack_app(path = nil, &block)
      return self if (block && block.call(self))
      the_app, the_rest = nil, nil
      if path.nil?
        @mapping.each do |host, location, match, app|
          if is_delegate?(app) 
            found = app.find_rack_app(path, &block)
            return found if found
          end
        end
        return nil
      else
        @mapping.each do |host, location, match, app|
          next unless path =~ match && rest = $1
          next unless rest.empty? || rest[0] == ?/
          the_app, the_rest = app, rest
          break
        end
        if the_app
          # we've found one
          if the_rest.empty? or the_rest=='/'
            block ? the_app.find_rack_app(nil, &block) : the_app
          else
            the_app.find_rack_app(the_rest, &block)
          end
        else
          nil
        end
      end
    end
    
    # Overrides FindRackAppDelegator._visit
    def _visit(path, block)
      block.call(path, self)
      @mapping.each do |host, location, match, app|
        next unless is_delegate?(app)
        app._visit((location.to_s.empty? ? path : path.chomp('/') + location.to_s), block)
      end
    end

  end # class URLMap
  
end # module Rack