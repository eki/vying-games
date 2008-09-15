# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

class Board::Infinite < Board

  attr_reader :padding, :cell_orientation

  prototype

  # Initializes a shapeless, infinite board.  This is accomplished by setting
  # up a Board with some width and height and then expanding it automatically
  # as necessary.  Unlike most boards, the infinite board is centered around
  # (0,0) and will include negative x and y coordinates.  This is so resizing
  # doesn't change the coordinate for any of the pieces already on the board.
  #
  # Board.occupied will contain only empty coordinates within the current 
  # bounds of the board.  Say the board extends from (-10, -5) in one corner
  # to (5, 10) in the other corner.  If board[1,1] is nil, it will be included
  # in board.occupied[nil].  If board[-11,-11] is nil (obviously, or we would
  # have resized the bounds to include it), it will not be present in 
  # board.occupied[nil].  If the board is subsequently resized by placing a
  # piece at board[-12,-12], the board[-11,-11] would be added automatically
  # to board.occupied[nil].
  #
  # When the board is resized, some padding of empty cells will be placed
  # around any occupied cells.  This is done for the benefit of methods like
  # Coords#neighbors and the Frontier plugin.  The default padding is only
  # 1 empty cell.
  #
  # NOTE:  You don't have to call Board::Infinite.new directly, you can use
  #        the convenience method Board.infinite.
  #
  # Takes an optional min_width, min_height pair.  Also accepts the following
  # parameters: 
  #
  #   :cell_shape  -  Valid values include [:square, :hexagon, :triangle].
  #                   The default is :square.
  #   :directions  -  Some subset of [:n, :e, :w, :s, :ne, :nw, :se, :sw].
  #                   This value represents cell connectivity, and effects
  #                   the results of methods like Coords#neighbors.  Only valid
  #                   if :cell_shape is :square.  The default is the full set 
  #                   of 8 directions.  If :cell_shape is :triangle, the
  #                   connectivity directions will vary for each cell.  See
  #                   Board#directions.  If :cell_shape is :hexagon, use the
  #                   :cell_orientation parameter to change the directions.
  #
  #   :cell_orientation - Valid values include [:horizontal, :vertical].
  #                       This is used to set the connectivity directions for
  #                       :hexagon cells.  The default is :horizontal.  This
  #                       can only be used with :cell_shape :hexagon.
  #
  #   :padding - Accepts an integer that represents how many empty cells of
  #              padding should exist around occupied cells.  This effects
  #              large the board grows when resized.  The default is 1.
  #
  # The :omit paramter normally accepted by Board, is not valid for infinite
  # boards.

  def initialize( min_width=nil, min_height=nil, h={} )
    if min_width.kind_of?( Hash )
      min_width, min_height, h = nil, nil, min_width
    elsif min_height.kind_of?( Hash )
      min_height, h = nil, min_height
    end

    @shape = :infinite

    @width  = min_width  || 11
    @height = min_height || 11

    @min_x = -((@width  / 2) - 1 + @width % 2)
    @max_x =   (@width  / 2)

    @min_y = -((@height / 2) - 1 + @height % 2)
    @max_y =   (@height / 2)

    @min_occupied_x, @max_occupied_x = 0, 0
    @min_occupied_y, @max_occupied_y = 0, 0

    @padding = h[:padding] || 1

    @cell_shape = h[:cell_shape] || :square

    @directions = h[:directions]

    case @cell_shape
      when :square
        @directions ||= [:n, :e, :w, :s, :ne, :nw, :se, :sw]

      when :triangle

        if @directions
          raise ":directions is not supported when :cell_shape is :triangle"
        end

        @up_directions   = [:w,:e,:s]
        @down_directions = [:n,:e,:w]

      when :hexagon

        @cell_orientation = h[:cell_orientation] || :horizontal

        case @cell_orientation
          when :horizontal
            @directions = [:n, :e, :w, :s, :nw, :se]
          when :vertical
            @directions = [:n, :e, :w, :s, :ne, :sw]
          else
            raise "#{@cell_orientation} is not a valid cell_orientation"
        end
      else
        raise "#{@cell_shape} is not a supported cell_shape for " +
              "an infinite Board"
    end

    super( h )   
  end

  def set( x, y, p )
    if resize?( x, y )
      resize( x, y )
    end

    old = @cells[ci( x, y )]

    before_set( x, y, old )

    @occupied[old].delete( Coord.new( x, y ) )
      
    if @occupied[p].nil? || @occupied[p].empty?
      @occupied[p] = [Coord.new( x, y )]
    else
      @occupied[p] << Coord.new( x, y )
    end

    @min_occupied_x = x if x < @min_occupied_x
    @max_occupied_x = x if x > @max_occupied_x

    @min_occupied_y = y if y < @min_occupied_y
    @max_occupied_y = y if y > @max_occupied_y

    @cells[ci( x, y )] = p

    after_set( x, y, p )

    p
  end

  def resize?( x, y )
    x - padding < @min_x || x + padding > @max_x ||
    y - padding < @min_y || y + padding > @max_y
  end

  def resize( x, y )
    if x - padding < @min_x
      @min_x = x - padding
    elsif x + padding > @max_x
      @max_x = x + padding
    end

    if y - padding < @min_y
      @min_y = y - padding
    elsif y + padding > @max_y
      @max_y = y + padding
    end

    w = (@max_x - @min_x) + 1
    h = (@max_y - @min_y) + 1

    cells = Array.new( w * h, nil )
    coords = CoordsProxy.new( self, Coords.new( bounds, [] ) )

    occupied = @occupied.deep_dup
    occupied[nil] = []

    @width.times do |ox|
      @height.times do |oy|
        cells[ox+oy*w] = @cells[ox+oy*@width]
      end
    end

    ((@min_y)..(@max_y)).each do |ny|
      ((@min_x)..(@max_x)).each do |nx|
        p = cells[nx+ny*w]
        occupied[p] << Coord[nx,ny] if p.nil?
      end
    end

    @width, @height = w, h
    @cells = cells
    @coords = coords
    @occupied = occupied
  end

  def in_bounds?( x, y )
    if x < @min_x || x > @max_x || y < @min_y || y > @max_y
      return nil
    end

    true
  end

  def bounds
    [Coord[@min_x, @min_y], Coord[@max_x, @max_y]]
  end

  def bounds_occupied
    [Coord[@min_occupied_x, @min_occupied_y], 
     Coord[@max_occupied_x, @max_occupied_y]]
  end

  def to_s
    b = bounds
    s = "bounds: [#{b.first.to_s( false )}, #{b.last.to_s( false )}]\n"

    s += "  " + " " * @min_x.abs + "0\n"
    s += "  " + "-" * width + "\n"

    ((@min_y)..(@max_y)).each do |y|
      s += y == 0 ? "0|" : " |"

      ((@min_x)..(@max_x)).each do |x|
        p  = self[x,y]
        s += p ? p.to_s[0..0] : ' '
      end

      s += "|\n"
    end
   
    s += "  " + "-" * width + "\n"
    s += "  " + " " * @min_x.abs + "0\n"

    s 
  end

end

