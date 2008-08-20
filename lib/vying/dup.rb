
class Array

  # Get a deep copy of this Array (and deep copies of all its elements).

  def deep_dup
    nd = [Symbol, NilClass, Fixnum, TrueClass, FalseClass]
    d = self.dup

    each_index do |i|
      if !nd.include?( self[i].class )
        d[i] = self[i].respond_to?( :deep_dup ) ? self[i].deep_dup : self[i].dup
      end
    end

    d
  end
end

class Hash

  # Get a deep copy of this Hash (and deep copies of all its elements).

  def deep_dup
    nd = [Symbol, NilClass, Fixnum, TrueClass, FalseClass]
    d = self.dup

    each do |k,v|
      if !nd.include?( v.class )
        d[k] = v.respond_to?( :deep_dup ) ? v.deep_dup : v.dup
      end
    end

    d
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

