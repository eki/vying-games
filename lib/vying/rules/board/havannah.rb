# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

class HavannahGroup
  attr_reader :coords, :side_map, :corner_map, :size

  def initialize( size, c=nil )
    @coords, @size = [], size
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
    (0...6).inject( 0 ) { |n,i| n + ((side_map >> i) & 1) }
  end

  def fork?
    sides >= 3
  end

  def bridge?
    corners > 2
  end

  def ring?
    @ring
  end

  def winning?
    ring? || bridge? || fork?
  end

  def |( group )
    g = HavannahGroup.new( size )
    g.instance_variable_set( "@coords",      coords      | group.coords )
    g.instance_variable_set( "@side_map",    side_map    | group.side_map )
    g.instance_variable_set( "@corner_map",  corner_map  | group.corner_map )
    g.instance_variable_set( "@ring",        ring?      || group.ring? )
    g
  end

  def <<( c )
    coords << c

    s1, s12 = size - 1, (size - 1) * 2

    case c
      when c.x == 0         && c.y == 0    then @corner_map |=  1
      when c.x == 0         && c.y == s1   then @corner_map |=  2
      when c.x == s1        && c.y == 0    then @corner_map |=  4
      when c.x == s12       && c.y == s1   then @corner_map |=  8
      when c.x == s1        && c.y == s12  then @corner_map |= 16
      when c.x == s12       && c.y == s12  then @corner_map |= 32

      when c.x == 0                        then @side_map   |=  1
      when                     c.y == 0    then @side_map   |=  2
      when c.x == s12                      then @side_map   |=  4
      when                     c.y == s12  then @side_map   |=  8
      when c.x - c.y == s12                then @side_map   |= 16
      when c.y - c.x == s12                then @side_map   |= 32
    end


    @side_map |= 1  if c.x == 0
    @side_map |= 2  if c.y == 0
    @side_map |= 4  if c.x + c.y == size - 1

    # add ring detection
  end

  def ==( o )
    o && coords == o.coords
  end
end

# Havannah
#
# For detailed rules see:  http://vying.org/games/havannah

class Havannah < Rules

  name    "Havannah"
  version "0.0.1"

  pie_rule

  players [:blue, :red]

  attr_reader :board, :groups

  def initialize( seed=nil )
    super

    @board = HexHexBoard.new
    @groups = { :blue => [], :red => [] }
  end

  def moves( player=nil )
    return []          unless player.nil? || has_moves.include?( player )

    board.unoccupied
  end

  def apply!( move )
    coord = Coord[move]

    board[coord] = turn

    new_groups = []
    HexHexBoard::DIRECTIONS.each do |d|
      n = board.coords.next( coord, d )

      groups[turn].delete_if do |g|
        if g.coords.include?( n )
          g << coord
          new_groups << g
        end
      end
    end

    if new_groups.empty?
      groups[turn] << HavannahGroup.new( board.width, coord )
    else
      g = HavannahGroup.new( board.width )
      groups[turn] << new_groups.inject( g ) { |m,a| m | a }
    end

    turn( :rotate )

    self
  end

  def final?
    players.any? { |p| winner?( p ) }
  end

  def winner?( player )
    groups[player].any? { |group| group.winning? }
  end

  def loser?( player )
    opp = player == :blue ? :red : :blue
    winner?( opp )
  end

  def hash
    [board,turn].hash
  end
end

