
require 'vying'

# This file contains pure ruby implementation of the C extension.
#
# This file should only be loaded if the C extension is unavailable.
#

class Coord
  @@coords_cache = {}

  def initialize( x, y )
    @x, @y = x, y
  end

  def self.[]( *args )
    if args.length == 2 && args.first.class == Fixnum &&
                           args.last.class  == Fixnum

      return Coord.new( args.first, args.last )

    elsif args.length == 1
      return args.first if args.first.class == Coord

      c = @@coords_cache[args.first]

      unless c
        x, y = args.first.x, args.first.y

        return nil if x.nil? || y.nil?

        c = new( x, y )
        @@coords_cache[args.first] = c
      end
 
      return c

    else
      return args.map do |arg|
        if arg.class == Coord
          arg
        else
          c = @@coords_cache[arg]

          unless c
            x, y = arg.x, arg.y

            c = !x || !y  ? nil : new( x, y )
            @@coords_cache[arg] = c
          end

          c
        end
      end     
    end

    return nil
  end

  def hash
    [x, y].hash
  end

  def ==( o )
    o.respond_to?( :x ) && o.respond_to?( :y ) &&
    x == o.x && y == o.y
  end

  def eql?( o )
    self == o
  end

  def +( o )
    Coord.new( x + o.x, y + o.y )
  end

  def direction_to( o )
    dx, dy = x - o.x, y - o.y

    if dx == 0
      if dy > 0
        return :n
      elsif dy < 0
        return :s
      end
    elsif dy == 0
      if dx > 0
        return :w
      elsif dx < 0
        return :e
      end
    elsif dx == dy
      if dx < 0 && dy < 0
        return :se
      elsif dx > 0 && dy > 0
        return :nw
      end
    elsif -dx == dy
      if dx > 0 && dy < 0
        return :sw
      elsif dx < 0 && dy > 0
        return :ne
      end
    end

    nil
  end
   
end

class Coords
  def include?( c )
    if c.x < 0 || c.x >= width || c.y < 0 || c.y >= height
      return nil
    end

    return true if omitted.empty?

    if omitted.length < coords.length
       ! omitted.include?( c )
    else
      coords.include?( c )
    end
  end

  def next( c, d )
    nc = c + DIRECTIONS[d]
    include?( nc ) ? nc : nil
  end
end

class Board
  def in_bounds?( x, y )
    if x < 0 || x >= width || y < 0 || y >= height
      return nil
    end

    true
  end

  def []( *args )
    if args.length == 2 && args.first.class == Fixnum &&
                           args.last.class  == Fixnum
      return get( args.first, args.last )
    elsif args.length == 1
      return args.first.nil? ? nil : get( args.first.x, args.first.y )
    else
      return args.map do |arg|
        get( arg.x, arg.y )
      end
    end

    nil
  end

  def []=( *args )
    if args.length == 3 && args[0].class == Fixnum &&
                           args[1].class == Fixnum
      return set( args[0], args[1], args[2] )
    elsif args.length == 2
      return args[0].nil? ? nil : set( args[0].x, args[0].y, args[1] )
    else
      args.each { |arg| set( arg.x, arg.y, args.last ) unless arg == args.last }
      return args.last
    end

    nil
  end

  def get( x, y )
    if in_bounds?( x, y )
      return @cells[ci( x, y )]
    end

    nil
  end

  def set( x, y, p )
     if in_bounds?( x, y )
      old = @cells[ci( x, y )]

      before_set( x, y, old )

      @occupied[old].delete( Coord.new( x, y ) )
      
      if @occupied[p].nil? || @occupied[p].empty?
        @occupied[p] = [Coord.new( x, y )]
      else
        @occupied[p] << Coord.new( x, y )
      end

      @cells[ci( x, y )] = p

      after_set( x, y, old )
    end

    p
  end

  def ci( x, y )
    x + y * width
  end
end

class OthelloBoard < Board
  def valid?( c, bp, directions = [:n,:s,:w,:e,:ne,:nw,:se,:sw] )
    return false if !self[c].nil?


    op = bp == :black ? :white : :black

    a = directions.zip( coords.neighbors_nil( c, directions ) )
    a.each do |d,nc|
      p = self[nc]
      next if p.nil? || p == bp

      i = nc
      while (i = coords.next( i, d ))
        p = self[i]
        return true if p == bp 
        break       if p.nil?
      end
    end

    false
  end

  def place( c, bp )
    op = bp == :black ? :white : :black

    directions = [:n,:s,:w,:e,:ne,:nw,:se,:sw]

    a = directions.zip( coords.neighbors_nil( c, directions ) )
    a.each do |d,nc|
      p = self[nc]
      next if p.nil? || p == bp

      bt = [nc]
      while (bt << coords.next( bt.last, d ))
        p = self[bt.last]
        break if p.nil?

        if p == bp
          bt.each { |bc| self[bc] = bp }
          break
        end
      end
    end

    self[c] = bp
  end

  def set( x, y, p )
    update_frontier( x, y, p )

    super( x, y, p )
  end

  private
  def update_frontier( x, y, p )
    c, w, h = Coord[x,y], width, height

    [:n, :s, :e, :w, :ne, :nw, :se, :sw].each do |d|
      nc = coords.next( c, d )

      if ! nc.nil? && self[nc].nil?
        frontier << nc
      end
    end

    frontier.delete( c )
    frontier.uniq!
    frontier
  end
end

