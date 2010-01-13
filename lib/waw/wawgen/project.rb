module Waw
  module Wawgen
    class Project

      # Upper case name of the project
      attr_reader :upname
  
      # Lower case name of the project
      attr_reader :lowname
  
      # Creates a project instance
      def initialize(name, folder=nil)
        @upname, @lowname = name, lower(name)
        @folder = folder
      end
  
      # Returns root folder
      def root
        @folder ||= lowname
      end
      alias :folder :root
  
      # Handle project name
      def lower(str)
        lowered = str.gsub(/[A-Z]/) {|s| s.swapcase} 
        lowered = lowered[1..-1] if lowered[0...1]=='_'
        lowered
      end
  
    end # class Project
  end # module Wawgen
end # module Waw