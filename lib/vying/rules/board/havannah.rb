# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class HavannahGroup
  attr_reader :coords, :side_map, :corner_map, :size, :board

  def initialize( board, c=nil )
    @board = board
    @coords, @size = [], board.length
    @side_map, @corner_map, @ring = 0, 0, false
    self << c if c
  end

  def initialize_copy( other )
    @coords = other.coords.dup
  end

  def sides
    (0...6).inject( 0 ) { |n,i| n + ((side_map >> i) & 1) }
  end

  def corners
    (0...6).inject( 0 ) { |n,i| n + ((corner_map >> i) & 1) }
  end

  def fork?
    sides >= 3
  end

  def bridge?
    corners >= 2
  end

  def ring?
    @ring
  end

  def winning?
    ring? || bridge? || fork?
  end

  def |( group )
    g = HavannahGroup.new( board )
    g.instance_variable_set( "@coords",      coords      | group.coords )
    g.instance_variable_set( "@side_map",    side_map    | group.side_map )
    g.instance_variable_set( "@corner_map",  corner_map  | group.corner_map )
    g.instance_variable_set( "@ring",        ring?      || group.ring? )
    g
  end

  def <<( c )
    coords << c

    s1, s12 = size - 1, (size - 1) * 2

       if c.x == 0         && c.y == 0    then @corner_map |=  1
    elsif c.x == 0         && c.y == s1   then @corner_map |=  2
    elsif c.x == s1        && c.y == 0    then @corner_map |=  4
    elsif c.x == s12       && c.y == s1   then @corner_map |=  8
    elsif c.x == s1        && c.y == s12  then @corner_map |= 16
    elsif c.x == s12       && c.y == s12  then @corner_map |= 32

    elsif c.x == 0                        then @side_map   |=  1
    elsif                     c.y == 0    then @side_map   |=  2
    elsif c.x == s12                      then @side_map   |=  4
    elsif                     c.y == s12  then @side_map   |=  8
    elsif c.x - c.y == s1                 then @side_map   |= 16
    elsif c.y - c.x == s1                 then @side_map   |= 32; end

    # ring detection

    return self if coords.length < 6  # minimum ring needs 6 cells

    ns = board.coords.neighbors( c )
    ms = ns.select { |nc| coords.include?( nc ) }
    return self unless ms.length >= 2  # can't form a ring without connecting
                                       # at least two cells

    # check for a "blob" -- a 7-cell hexagon pattern

    (ms + [c]).each do |bc|
      bns = board.coords.neighbors( bc )
      if bns.length == 6 && bns.all? { |bnc| coords.include?( bnc ) }
        @ring = true
        return self
      end
    end

    # check for rings with holes
    #
    # Iterate over empty neighbors and their neighbors, marking them as we
    # go.  If we can find an edge, the empty neighbor is not contained in
    # a ring.  Note, the "empty" neighbors are simply not a part of this
    # group.  That means they may be empty or owned by an opponent.
    #
    # Break and return immediately if a ring is found.
    #
    # On subsequent passes it's enough to find a previously marked coord,
    # because we know it must be connected to an edge.
    #
    # This doesn't find blob patterns, hence the previous check.

    es = ns - ms

    marked = []
    es.each_with_index do |sc, i|
      check, found_marked, found = [sc], false, true

      until check.empty?
        nc = check.pop
        marked << nc

        if nc == sc || ! coords.include?( nc )
          board.coords.neighbors( nc ).each do |nnc|
            if i > 0 && marked.include?( nnc )
              found_marked = true
              break
            end

            check << nnc unless marked.include?( nnc ) || coords.include?( nnc )
          end
        end

        if found_marked       ||
           nc.x == 0          || nc.y == 0   || 
           nc.x == s12        || nc.y == s12 ||
           nc.x - nc.y == s12 || nc.y - nc.x == s12

          found = false
          break
        end
      end

      if found
        @ring = true
        break
      end     
    end

    self
  end

  def ==( o )
    o && coords == o.coords
  end

end

# Havannah
#
# For detailed rules see:  http://vying.org/games/havannah

Rules.create( "Havannah" ) do
  name    "Havannah"
  version "0.0.1"

  pie_rule

  players :blue, :red

  cache :moves

  position do
    attr_reader :board, :groups
    ignore :groups

    def init
      @board = Board.hexagon( 10 )
      @groups = { :blue => [], :red => [] }
    end

    def moves
      return []  if final?

      board.unoccupied
    end

    def apply!( move )
      coord = Coord[move]

      board[coord] = turn

      new_groups = []
      board.directions.each do |d|
        n = board.coords.next( coord, d )

        groups[turn].delete_if do |g|
          if g.coords.include?( n )
            g << coord
            new_groups << g
          end
        end
      end

      if new_groups.empty?
        groups[turn] << HavannahGroup.new( board, coord )
      else
        g = HavannahGroup.new( board )
        groups[turn] << new_groups.inject( g ) { |m,a| m | a }
      end

      rotate_turn

      self
    end

    def final?
      board.unoccupied.empty? || players.any? { |p| winner?( p ) }
    end

    def winner?( player )
      (g = groups[player].last) && g.winning?
    end

    def loser?( player )
      winner?( opponent( player ) )
    end

    def draw?
      board.unoccupied.empty? && players.all? { |p| ! winner?( p ) }
    end
  end

end

