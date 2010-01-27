module Waw
  module Wawgen
    class Project

      # Upper case name of the project
      attr_reader :upname
  
      # Lower case name of the project
      attr_reader :lowname
  
      # Creates a project instance
      def initialize(name, folder=nil)
        @upname, @lowname = name, WLang::encode(name, 'ruby/method-case')
        @folder = folder
      end
  
      # Returns root folder
      def root
        @folder ||= lowname
      end
      alias :folder :root
  
    end # class Project
  end # module Wawgen
end # module Waw