# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

class Board::Rect < Board

  prototype

  # Initializes a rectangular board.
  #
  # NOTE:  You don't have to call Board::Rect.new directly, you can use
  #        the convenience method Board.rect.
  #
  # Requires a width and height for the board.  In addition to the options
  # provided by Board, you may provide:
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

  def initialize(width, height, h={})
    @shape = :rect

    @width, @height = width, height

    @cell_shape = h[:cell_shape] || :square

    case @cell_shape
      when :square
        h[:directions] ||= [:n, :e, :w, :s, :ne, :nw, :se, :sw]

      when :triangle

        if h[:directions]
          raise ':directions is not supported when :cell_shape is :triangle'
        end

      else
        raise "#{@cell_shape} is not a supported cell_shape for a rect Board"
    end

    super(h)
  end

end
