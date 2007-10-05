require 'vying/rules'
require 'vying/board/board'

class MinesweeperBoard < Board
  def reveal( coord, mines )
    p = [coord]
    if mines.include? coord
      self[coord] = :b
    else
      n = coords.neighbors( coord )
      self[coord] = n.inject( 0 ) { |s,c| mines.include?( c ) ? s+1 : s }
      n.each { |c| p += reveal( c, mines ) if self[c].nil? } if self[coord] == 0
    end
    p
  end
end

class Minesweeper < Rules

  info :name        => 'Minesweeper',
       :description => '9x9, 10 bomb Minesweeper'

  attr_reader :board, :mines, :unused_moves

  random

  censor   :one => [:mines]
  players [:one]

  @@init_moves = Coords.new( 9, 9 ).map { |c| c.to_s }

  def initialize( seed=nil )
    super

    @mines = []
    a = (0...81).to_a.sort_by { rng.rand }
    10.times { |i| @mines << Coord[a[i]/9,a[i]%9] }

    @board = MinesweeperBoard.new( 9, 9 )
    @unused_moves = @@init_moves.dup
  end

  def moves( player=nil )
    return [] if final?
    unused_moves
  end

  def apply!( move )
    c = Coord[move] 

    revealed = board.reveal( c, mines )
    if revealed.any? { |rc| board[rc] == :b }
      unused_moves.clear
    else
      @unused_moves -= revealed.map { |rc| rc.to_s }
    end

    self
  end

  def final?
    winner? || loser?
  end

  def winner?( player=:one )
    unused_moves.size == 10
  end

  def loser?( player=:one )
    unused_moves.empty?
  end
end

