module Rack
  
  # Some overridings of Delegator
  class URLMap
    
    # Overrides Delegator.find_rack_app
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
    
    # Overrides Delegator._visit
    def _visit(path, block)
      block.call(path, self)
      @mapping.each do |host, location, match, app|
        # seems required on some configurations where rack does not acts
        # as expected (3 arguments and not 4)
        app = match if app.nil? 
        unless is_delegate?(app)
          Waw.logger.warn("We found a rack application which is not a delegator on #{path}: #{app.inspect}!")
          next 
        end
        app._visit((location.to_s.empty? ? path : path.chomp('/') + location.to_s), block)
      end
    end

  end # class URLMap  

end # module Rack