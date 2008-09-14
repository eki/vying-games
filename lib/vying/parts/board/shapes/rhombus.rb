# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

class Board::Rhombus < Board

  attr_reader :cell_orientation

  prototype

  # Initializes a rhombus board.
  #
  # NOTE:  You don't have to call Board::Rhombus.new directly, you can use
  #        the convenience method Board.rhombus.
  #
  # Requires a width and height for the board.  In addition to the options
  # provided by Board, you may provide:
  #
  #   :cell_shape  -  Valid values include [:hexagon].  In the future :triangle
  #                   might be added.  The default is :hexagon.
  #
  #   :cell_orientation - Valid values include [:horizontal, :vertical].
  #                       This is used to set the connectivity directions for
  #                       :hexagon cells.  The default is :vertical.
  #

  def initialize( width, height, h={} )
    @shape = :rhombus

    @width, @height = width, height

    @cell_shape = h[:cell_shape] || :hexagon

    @cell_orientation = h[:cell_orientation]

    case @cell_shape
      when :hexagon

        @cell_orientation ||= :vertical

        case @cell_orientation
          when :horizontal
            @directions = [:n, :s, :e, :w, :nw, :se]
          when :vertical
            @directions = [:n, :s, :e, :w, :ne, :sw]
          else
            raise "#{@cell_orientation} is not a valid cell_orientation"
        end
      else
        raise "#{@cell_shape} is not a supported cell_shape for a rhombus Board"
    end

    super( h )   
  end

end

