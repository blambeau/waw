module Waw
  class StaticController < ::Waw::Controller
    class AbstractMatcher
      include Waw::ScopeUtils

      # Waw access on which this matcher is defined
      attr_reader :wawaccess
      
      def initialize(wawaccess)
        @wawaccess = wawaccess
      end
      
      # Returns wawaccess's folder
      def folder
        wawaccess.folder
      end
      
      # Returns requested path
      def req_path
        wawaccess.req_path
      end
      
      def &(other)
        unless other.is_a?(AbstractMatcher)
          raise ArgumentError, "Matcher expected for &, #{other} received"
        end
        AndMatcher.new(wawaccess, self, other)
      end
      
      def |(other)
        unless other.is_a?(AbstractMatcher)
          raise ArgumentError, "Matcher expected for |, #{other} received"
        end
        OrMatcher.new(wawaccess, self, other)
      end
      
      def negate
        NegateMatcher.new(wawaccess, self)
      end
      
    end
    
    class Matcher < AbstractMatcher
      
      # Matcher's predicate
      attr_reader :predicate
      
      # Creates a matcher instance
      def initialize(wawaccess, predicate)
        super(wawaccess)
        @predicate = predicate
      end
      
      # Does the matcher matches a given path?
      def matches?(env)
        instance_eval &predicate
      end
      
    end # class Matcher

    class NegateMatcher < AbstractMatcher

      def initialize(wawaccess, operand)
        super(wawaccess)
        @operand = operand
      end
      
      # Does the matcher matches a given path?
      def matches?(env)
        !@operand.matches?(env)
      end
      
    end

    class AndMatcher < AbstractMatcher

      def initialize(wawaccess, left, right)
        super(wawaccess)
        @left, @right = left, right
      end
      
      # Does the matcher matches a given path?
      def matches?(env)
        @left.matches?(env) && @right.matches?(env)
      end
      
    end # class AndMatcher

    class OrMatcher < AbstractMatcher

      def initialize(wawaccess, left, right)
        super(wawaccess)
        @left, @right = left, right
      end
      
      # Does the matcher matches a given path?
      def matches?(env)
        @left.matches?(env) || @right.matches?(env)
      end
      
    end # class AndMatcher
    
  end # class StaticController
end # module Waw
