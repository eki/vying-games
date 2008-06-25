# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class Coords
  include Enumerable
  extend Memoizable

  class << self
    extend Memoizable
    memoize :new
  end

  attr_reader :width, :height, :coords, :irregular, :omitted
  protected :coords

  DIRECTIONS = { :n  => Coord.new( 0, -1 ),  :s  => Coord.new( 0, 1 ),
                 :w  => Coord.new( -1, 0 ),  :e  => Coord.new( 1, 0 ),
                 :nw => Coord.new( -1, -1 ), :ne => Coord.new( 1, -1 ),
                 :sw => Coord.new( -1, 1 ),  :se => Coord.new( 1, 1 ) }

  def initialize( w, h, omit=[] )
    @width = w
    @height = h
    @coords = (Array.new( w*h ) { |i| Coord.new( i%w, i/w ) } - omit).freeze
    @omitted = omit.dup.freeze
    @irregular = ! omit.empty?
  end

  def each
    coords.each { |c| yield c }
  end

  def dup
    self
  end

  def to_a
    coords
  end

  def length
    coords.length
  end

  def _dump( depth=-1 )
    Marshal.dump( [width, height, omitted] )
  end

  def self._load( str )
    width, height, omitted = Marshal.load( str )
    if omitted.empty?          # extra care to make sure memoize works
      new( width, height )
    else
      new( width, height, omitted )
    end
  end

  def hash
    [width, height].hash
  end

  def group_by
    r, a = {}, []
    each do |c|
      y = yield c
      r[y] ||= a.size
      (a[r[y]] ||= []) << c
    end
    a
  end

  def row( coord )
    coords.select { |c| coord.y == c.y }
  end

  def column( coord )
    coords.select { |c| coord.x == c.x }
  end

  def diagonal( coord, slope=1 )
    coords.select { |c| slope*(coord.y-c.y) == (coord.x-c.x) }
  end

  def neighbors_nil( coord, directions=[:n,:ne,:e,:se,:s,:sw,:w,:nw] )
    a = directions.map { |dir| coord + DIRECTIONS[dir] }
    a.map { |c| (! include?( c )) ? nil : c }
  end

  def neighbors( coord, directions=[:n,:ne,:e,:se,:s,:sw,:w,:nw] )
    a = directions.map { |dir| coord + DIRECTIONS[dir] }
    a.reject! { |c| ! include?( c ) }
    a
  end

  def ring( coord, d )
    coords.select do |c| 
      dx = (c.x - coord.x).abs
      dy = (c.y - coord.y).abs

      (dx == d && dy <= d) || (dx <= d && dy == d)
    end
  end

  def to_s
    inject( '' ) { |s,c| s + "#{c}" }
  end

  memoize :row
  memoize :column
  memoize :diagonal
  memoize :neighbors
  memoize :neighbors_nil
  memoize :ring
end

