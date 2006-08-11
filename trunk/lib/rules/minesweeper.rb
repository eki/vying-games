require 'board/standard'
require 'game'

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

  attr_reader :board, :mines, :unused_ops

  random

  censor   :one => [:mines]
  players [:one]

  @@init_ops = Coords.new( 9, 9 ).map { |c| c.to_s }

  def initialize( seed=nil )
    super

    @mines = []
    a = (0...81).to_a.sort_by { rng.rand }
    10.times { |i| @mines << Coord[a[i]/9,a[i]%9] }

    @board = MinesweeperBoard.new( 9, 9 )
    @unused_ops = @@init_ops.dup
  end

  def op?( op, player=nil )
    unused_ops.include?( op.to_s )
  end

  def ops( player=nil )
    final? || unused_ops == [] ? nil : unused_ops
  end

  def apply!( op )
    c = Coord[op] 

    revealed = board.reveal( c, mines )
    if revealed.any? { |rc| board[rc] == :b }
      unused_ops.clear
    else
      @unused_ops -= revealed.map { |rc| rc.to_s }
    end

    self
  end

  def final?
    winner? || loser?
  end

  def winner?( player=:one )
    unused_ops.size == 10
  end

  def loser?( player=:one )
    unused_ops.empty?
  end
end

