module Rack
  # Extends Rack application with utilities. This module may be included
  # by standard rack applications delegating to another one. The later is
  # expected to be returned by delegate. Methods are intended to be 
  # overriden for matching specific situations.
  module Delegator

    # Returns delegate rack application. By default, returns @app.
    def delegate
      @app
    end
    
    # Checks if an app may be safely considered in the chain
    def is_delegate?(app)
      Delegator===app
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
      nil
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
    
  end # module Delegator
end # module Rack