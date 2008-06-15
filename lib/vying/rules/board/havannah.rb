# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

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

    ns = HexHexBoard::DIRECTIONS.map { |d| c + Coords::DIRECTIONS[d] }
    ns.reject! do |nc| 
      nc.x < 0          || nc.y < 0   || 
      nc.x > s12        || nc.y > s12 ||
      nc.x - nc.y > s12 || nc.y - nc.x > s12
    end

    ms = ns.select { |nc| coords.include?( nc ) }
    return self unless ms.length >= 2

    es = ns - ms

    es.each do |sc|
      check, marked, found = [sc], [], true

      until check.empty?
        nc = check.pop
        marked << nc

        if nc == sc || ! coords.include?( nc )
          nss = HexHexBoard::DIRECTIONS.map { |d| nc + Coords::DIRECTIONS[d] }
          nss.each do |nnc|
            check << nnc unless marked.include?( nnc ) || coords.include?( nnc )
          end
        end

        if nc.x == 0          || nc.y == 0   || 
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

  position do
    attr_reader :board, :groups

    def init
      @board = HexHexBoard.new
      @groups = { :blue => [], :red => [] }
    end

    def moves( player=nil )
      return []  unless player.nil? || has_moves.include?( player )
      return []  if final?

      board.unoccupied
    end

    def apply!( move, player=nil )
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
        groups[turn] << HavannahGroup.new( board.length, coord )
      else
        g = HavannahGroup.new( board.length )
        groups[turn] << new_groups.inject( g ) { |m,a| m | a }
      end

      rotate_turn

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

end

