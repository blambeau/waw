class Class
  def |(validator)
    ::Waw::Validation.to_validator(self) | validator
  end
  def &(validator)
    ::Waw::Validation.to_validator(self) & validator
  end
  def not()
    ::Waw::Validation.to_validator(self).not
  end
end