class Hash

  def keep!(*keys)
    self.delete_if{|k,v| !keys.include?(k)}
  end

  def keep(*keys)
    self.dup.delete_if{|k,v| !keys.include?(k)}
  end

  def forget!(*keys)
    self.delete_if{|k,v| keys.include?(k)}
  end

  def forget(*keys)
    self.dup.delete_if{|k,v| keys.include?(k)}
  end

  def symbolize_keys
    copy = Hash.new
    self.each_pair {|k,v| copy[k.to_s.to_sym] = v}
    copy
  end
  
  def methodize
    copy = self.symbolize_keys
    keys.each {|key| 
      copy.instance_eval <<-EOF
        def #{key}
          self[:"#{key}"]
        end
      EOF
    }
    copy
  end

  def unsymbolize_keys
    copy = Hash.new
    self.each_pair {|k,v| copy[k.to_s] = v}
    copy
  end

  def to_url_query
    ::Rack::Utils.build_query(self)
  end

end
