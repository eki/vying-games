# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class YGroup
  attr_reader :coords, :side_map, :size

  def initialize( size, c=nil )
    @coords, @side_map, @size = [], 0, size
    self << c if c
  end

  def initialize_copy( other )
    @coords = other.coords.dup
  end

  def winning?
    side_map == 7
  end

  def sides
    (side_map & 1) + ((side_map >> 1) & 1) + ((side_map >> 2) & 1)
  end

  def |( group )
    g = YGroup.new( size )
    g.instance_variable_set( "@coords",    coords    | group.coords )
    g.instance_variable_set( "@side_map",  side_map  | group.side_map )
    g
  end

  def <<( c )
    coords << c
    @side_map |= 1  if c.x == 0
    @side_map |= 2  if c.y == 0
    @side_map |= 4  if c.x + c.y == size - 1
  end

  def ==( o )
    o && coords == o.coords
  end
end

# Y
#
# For detailed rules see:  http://vying.org/games/y

Rules.create( "Y" ) do
  name    "Y"
  version "0.8.0"

  players :blue, :red

  option :board_size, :default => 12, :values => [12, 13, 14]

  pie_rule

  cache :init, :moves

  position do
    attr_reader :board, :groups

    def init
      @board = Board.new( :shape => :triangle, 
                          :length => @options[:board_size] )

      @groups = { :blue => [], :red => [] }
    end

    def moves
      board.unoccupied
    end

    def apply!( move )
      coord = Coord[move]

      board[coord] = turn

      new_groups = []
      [:n, :s, :e, :w, :ne, :sw].each do |d|
        n = board.coords.next( coord, d )

        groups[turn].delete_if do |g|
          if g.coords.include?( n )
            g << coord
            new_groups << g
          end
        end
      end

      if new_groups.empty?
        groups[turn] << YGroup.new( board.width, coord )
      else
        g = YGroup.new( board.width )
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
      winner?( opponent( player ) )
    end

    def hash
      [board,turn].hash
    end
  end

end

