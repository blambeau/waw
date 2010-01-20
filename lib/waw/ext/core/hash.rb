class Hash

  def keep!(*keys)
    self.delete_if{|k,v| !keys.include?(k)}
  end

  def keep(*keys)
    self.dup.delete_if{|k,v| !keys.include?(k)}
  end

  def symbolize_keys
    copy = Hash.new
    self.each_pair {|k,v| copy[k.to_s.to_sym] = v}
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
