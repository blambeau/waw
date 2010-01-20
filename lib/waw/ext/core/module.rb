$waw_deprecated_io = STDOUT
class Module
  
  def deprecated(msg = "The method ${name} is deprecated")
    @deprecated = msg
  end
  
  # If a signature has been installed, let the next added method
  # become an action
  def method_added(name)
    if @deprecated
      deprecated, @deprecated = @deprecated.gsub(/#{Regexp.escape('${name}')}/, name.to_s), nil
      method = instance_method(name)
      define_method name do |*args|
        $waw_deprecated_io << deprecated << " (#{caller[0]})\n"
        method.bind(self).call(*args)
      end 
    end
  end

end