class Regexp
  def to_validator
    Waw::Validation.validator {|*values| values.all?{|val| self =~ val}}
  end
end