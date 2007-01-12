
class Array
  def x
    self[0]
  end

  def y
    self[1]
  end
end

class Symbol
  def x
    to_s[0]-97
  end

  def y
    to_s =~ /\w(\d+)$/
    $1.to_i-1
  end
end

class ClassicBoard

  attr_reader :width, :height, :cells

  def initialize( w=8, h=8 )
    @cells, @width, @height, @key = Array.new( w*h, 0 ), w, h, [:empty]
  end

  def initialize_copy( original )
    @cells = original.cells.dup
  end

  def []( *a )
    if a.length == 2 && a.all? { |o| o.kind_of? Fixnum }
      @key[@cells[c_to_i(a)]]
    else
      ps = a.map do |o|
        @key[@cells[c_to_i(o)]]
      end

      ps.length == 1 ? ps.first : ps
    end
  end

  def []=( *a )
    p = a.pop

    if a.length == 2 && a.all? { |o| o.kind_of? Fixnum }
      @cells[c_to_i(a)] = ki( p )
    else
      a.each do |o|
        @cells[c_to_i(o)] = ki( p )
      end
    end
    p
  end

  def c_to_i( c )
    c.x + c.y * width
  end

  def ki( p )
    ki = @key.index( p )
    @key << p unless ki
    ki || @key.length - 1
  end

end

