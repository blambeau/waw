module Rack
  module FindRackAppDelegator
    # Finds a rack application that matches a given path and block
    # checking for matching
    def find_rack_app(path, &block)
      return self if (block && block.call(self))
      @app ? @app.find_rack_app(path, &block) : nil
    end
  end
  class Builder
    include FindRackAppDelegator
  end
  module Session
    module Abstract
      class ID
        include FindRackAppDelegator
      end
    end
  end
  class CommonLogger
    include FindRackAppDelegator
  end
  class ShowExceptions
    include FindRackAppDelegator
  end
  class Static
    include FindRackAppDelegator
  end
  class URLMap
    # Finds a rack application that matches a given path and block
    # checking for matching
    def find_rack_app(path, &block)
      return self if (block && block.call(self))
      the_app, the_rest = nil, nil
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
end # module Rack