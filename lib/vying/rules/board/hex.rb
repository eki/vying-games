# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class HexGroup
  attr_reader :coords, :side_map, :size

  def initialize( size, c=nil )
    @coords, @side_map, @size = [], 0, size
    self << c if c
  end

  def initialize_copy( other )
    @coords = other.coords.dup
  end

  def winning?( player )
    (player == :red  && (side_map & 10) == 10) ||
    (player == :blue && (side_map &  5) ==  5)
  end

  def |( group )
    g = HexGroup.new( size )
    g.instance_variable_set( "@coords",    coords    | group.coords )
    g.instance_variable_set( "@side_map",  side_map  | group.side_map )
    g
  end

  def <<( c )
    coords << c
    @side_map |= 1  if c.x == 0
    @side_map |= 2  if c.y == 0
    @side_map |= 4  if c.x == size - 1
    @side_map |= 8  if c.y == size - 1
  end

  def ==( o )
    o && coords == o.coords
  end
end

# Hex
#
# For detailed rules see:  http://vying.org/games/hex

Rules.create( "Hex" ) do
  name    "Hex"
  version "0.1.0"

  players :red, :blue

  option :board_size, :default => 11, :values => (9..19).to_a

  pie_rule

  cache :moves

  position do
    attr_reader :board, :groups

    def init
      length = @options[:board_size]
      @board = Board.new( :shape => :rhombus, 
                          :width => length, :height => length )
      @groups = { :blue => [], :red => [] }
    end

    def moves
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
        groups[turn] << HexGroup.new( board.width, coord )
      else
        g = HexGroup.new( board.width )
        groups[turn] << new_groups.inject( g ) { |m,a| m | a }
      end

      rotate_turn

      self
    end

    def final?
      players.any? { |p| winner?( p ) }
    end

    def winner?( player )
      groups[player].any? { |group| group.winning?( player ) }
    end

    def loser?( player )
      winner?( opponent( player ) )
    end

    def hash
      [board,turn].hash
    end
  end

end

