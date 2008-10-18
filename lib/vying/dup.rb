
class Object
  def deep_dup
    dup
  end
end

class Symbol
  def deep_dup
    self
  end
end

class NilClass
  def deep_dup
    self
  end
end

class Fixnum
  def deep_dup
    self
  end
end

class Bignum
  def deep_dup
    self
  end
end

class TrueClass
  def deep_dup
    self
  end
end

class FalseClass
  def deep_dup
    self
  end
end

class Array

  # Get a deep copy of this Array (and deep copies of all its elements).

  def deep_dup
    self.dup.map! { |o| o.deep_dup }
  end
end

class Hash

  # Get a deep copy of this Hash (and deep copies of all its elements).

  def deep_dup
    d = dup
    d.each { |k, v| d[k] = v.deep_dup }
  end

  # Define an actual hash function

  def hash
    [keys, values].hash
  end

  # Define eql? in terms of == which seems to behave in a nicer manner

  def eql?( o )
    self == o
  end
end

