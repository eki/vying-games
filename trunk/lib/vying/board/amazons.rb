require 'vying/board/board'

class Territory
  attr_reader :white, :black, :coords

  def initialize( board, coords, queens=nil )
    if queens.nil?
      @white = board.occupied[:white]
      @black = board.occupied[:black]
    else
      @white = queens.select { |q| board[q] == :white }
      @black = queens.select { |q| board[q] == :black }
    end

    @coords = coords
  end

  def initialize_copy( original )
    super
    @white = original.white.dup
    @black = original.black.dup
    @coords = original.coords.dup
  end

  class << self
    def []( board, queens=nil )
      t = new board, [], queens
      t.update board, queens
    end
  end

  def update( board, queens=nil )
    if queens.nil?
      @white = board.occupied[:white]
      @black = board.occupied[:black]

      queens ||= white + black
    else
      @white = queens.select { |q| board[q] == :white }
      @black = queens.select { |q| board[q] == :black }
    end

    queens_found, coords_found = check( board, queens.first )

    if queens_found.length == queens.length
      @coords = coords_found
      return self
    else
      return [Territory.new( board, coords_found, queens_found ),
              Territory[board, queens - queens_found]]
    end

  end

  def check( board, start )
    queens_found, coords_found, all, todo = [], [], {start => start}, [start]

    while (c = todo.pop)
      p = board[c]
      if p.nil?
        coords_found.push c
      elsif p == :white || p == :black
        queens_found.push c
        coords_found.push c
      end

      board.coords.neighbors( c ).each do |nc|
        unless board[c] == :arrow || all[nc]
          todo.push( nc )
          all[nc] = nc
        end
      end
    end

    return [queens_found, coords_found]
  end

  def move( sc, ec )
    if white.include?( sc )
      white.delete( sc )
      white << ec
    elsif black.include?( sc )
      black.delete( sc )
      black << ec
    end
  end

  def eql?( o )
    white == o.white &&
    black == o.black &&
    coords == o.coords
  end

  def ==( o )
    eql? o
  end

end


class AmazonsBoard < Board

  attr_reader :territories

  INIT_WQS = [Coord[0,3], Coord[3,0], Coord[6,0], Coord[9,3]]
  INIT_BQS = [Coord[0,6], Coord[3,9], Coord[6,9], Coord[9,6]]

  def initialize
    super( 10, 10 )

    self[*INIT_WQS] = :white
    self[*INIT_BQS] = :black

    #@territories = [Territory[self]]
    @territories = [Territory.new( self, coords.to_a, INIT_WQS + INIT_BQS )]
  end

  def initialize_copy( original )
    super
    @territories = []
    original.territories.each { |t| @territories << t.dup }
  end

  def clear
    @territories.clear
    super
  end

  def update_territories
    @territories = @territories.map { |t| t.update( self, t.white + t.black ) }
    @territories.flatten!
    @territories
  end

end

