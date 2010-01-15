module +(project.upname)
  #
  # Provides web services as Ruby methods.
  #
  class ServicesController < ::Waw::ActionController
    
    # Who is currently saying hello
    attr_accessor :who
    
    # Say hello to someone
    signature {
      validation :who, mandatory, :who_is_mandatory
    }
    routing {
      upon 'validation-ko' do feedback() end
      upon 'success/ok'    do redirect(:url => "/index") end
    }
    def say_hello(params)
      self.who = params[:who]
      :ok
    end
    
  end # class ServicesController
end # module +(project.upname)