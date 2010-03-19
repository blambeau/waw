# Force some auto loading ...
require 'rubygems'
require 'rack'
::Rack::Session::Pool

# Let the delegator be known
require 'waw/ext/rack/delegator'

# Install the delegator on all standard Rack applications
[::Rack::Builder, ::Rack::Session::Abstract::ID, ::Rack::CommonLogger,
 ::Rack::ShowExceptions, ::Rack::Static, ::Rack::URLMap, ::Rack::Reloader].each do |rack_app|
   rack_app.instance_eval <<-EOF
     include ::Rack::Delegator
   EOF
end

# Makes overrides now
#require 'waw/ext/rack/builder.rb'
require 'waw/ext/rack/urlmap.rb'