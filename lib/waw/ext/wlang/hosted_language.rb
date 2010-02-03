module WLang
  class HostedLanguage
    include ::Waw::ScopeUtils
    
    # 
    # Overrides the original version that always raises an UndefinedVariableError 
    # to put waw scoping utilities as low-level variables in all wlang scopes as
    # well as installed resources.
    #
    def variable_missing(name)
      if self.respond_to?(name)
        self.send(name)
      elsif resources && resources.has_resource?(name)
        resources[name]
      else
        raise ::WLang::UndefinedVariableError.new(nil, nil, nil, name)
      end
    end
    
  end # class HostedLanguage
end # module WLang