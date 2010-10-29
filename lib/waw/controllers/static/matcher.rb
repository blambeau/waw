module Waw
  class StaticController < ::Waw::Controller
    class Matcher
      include Waw::ScopeUtils
      
      # Waw access on which this matcher is defined
      attr_reader :wawaccess
      
      # Matcher's predicate
      attr_reader :predicate
      
      # Creates a matcher instance
      def initialize(wawaccess, predicate)
        @wawaccess = wawaccess
        @predicate = predicate
      end
      
      # Returns wawaccess's folder
      def folder
        wawaccess.folder
      end
      
      # Returns requested path
      def req_path
        wawaccess.req_path
      end
      
      # Does the matcher matches a given path?
      def matches?(env)
        instance_eval &predicate
      end
      
    end # class Matcher
  end # class StaticController
end # module Waw
