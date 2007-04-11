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

    q = queens.first

    n = board.coords.neighbors( q )
    n.reject! { |c| board[c] == :arrow }
    queens_found, coords_found = check( board, [q], [q], n )

    if queens_found.length == queens.length
      @coords = coords_found
      return self
    else
      return [Territory.new( board, coords_found, queens_found ),
              Territory[board, queens - queens_found]]
    end

  end

  def check( board, queens_found, coords_found, todo )
    return [queens_found, coords_found] if todo.empty?

    todo.each do |c|
      queens_found << c if board[c] == :white || board[c] == :black
      coords_found << c if board[c] != :arrow
    end

    todo = todo.map { |c| board.coords.neighbors( c ) }
    todo.flatten!
    todo.reject! { |c| board[c] == :arrow }
    todo.uniq!

    todo -= coords_found

    queens_found.uniq!

    check( board, queens_found, coords_found, todo )
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

  def initialize
    super( 10, 10 )

    wqs = [Coord[0,3], Coord[3,0], Coord[6,0], Coord[9,3]]
    bqs = [Coord[0,6], Coord[3,9], Coord[6,9], Coord[9,6]]

    wqs.each { |c| self[c] = :white }
    bqs.each { |c| self[c] = :black }

    @territories = [Territory[self]]
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

