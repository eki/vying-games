require 'vying/board/boardext'

class Array
  def x
    self[0]
  end

  def y
    self[1]
  end
end

class String
  def x
    self[0]-97
  end

  def y
    self =~ /\w(\d+)$/
    $1.to_i-1
  end

  def to_coords
    scan( /[a-z]\d+/ ).map { |s| Coord[s] }
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

  def to_coords
    to_s.scan( /[a-z]\d+/ ).map { |s| Coord[s] }
  end
end

class Coord
  attr_reader :x, :y


  def <=>( c )
    (t = y <=> c.y) != 0 ? t : x <=> c.x
  end

  def to_s
    "#{(97+x).chr}#{y+1}"
  end

  def inspect
    to_s
  end

  def to_coords
    [self]
  end
end

