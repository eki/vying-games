# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

class Board::Square < Board

  public_class_method :new

  prototype

  # Initializes a square board.
  #
  # NOTE:  You don't have to call Board::Shape.new directly, you can use
  #        the convenience method Board.square.
  #
  # Requires a length for each side of the board.  In addition to the 
  # options provided by Board, you may provide:
  #
  #   :cell_shape  -  Valid values include [:square, :triangle].  In the
  #                   future :hexagon will be added.  The default is :square.
  #   :directions  -  Some subset of [:n, :e, :w, :s, :ne, :nw, :se, :sw].
  #                   This value represents cell connectivity, and effects
  #                   the results of methods like Coords#neighbors.  Only valid
  #                   if :cell_shape is :square.  The default is the full set 
  #                   of 8 directions.  If :cell_shape is :triangle, the
  #                   connectivity directions will vary for each cell.  See
  #                   Board#directions.
  #

  def initialize( length, h={} )
    @shape = :square

    @width = @height = @length = length

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

      else
        raise "#{@cell_shape} is not a supported cell_shape for a square Board"
    end

    super( h )   
  end

end

