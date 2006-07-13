# NAME
#   Minesweeper
#
# RESOURCES
#   Wikipedia <http://en.wikipedia.org/wiki/Minesweeper_(computer_game)>
#

require 'board/standard'
require 'game'

class MinesweeperBoard < Board
  def reveal( coord, mines )
    if mines.include? coord
      self[coord] = :b
    else
      n = coords.neighbors( coord )
      self[coord] = n.inject( 0 ) { |s,c| mines.include?( c ) ? s+1 : s }
      p = [coord]
      n.each { |c| p += reveal( c, mines ) if self[c].nil? } if self[coord] == 0
    end
    p
  end
end

class Minesweeper < Rules

  INFO = info( __FILE__ )

  class Position < Struct.new( :board, :mines, :seed, :unused_ops )
    def to_s
      "Seed: #{seed}\nBoard:\n#{board}"
    end
  end

  @@init_ops = Coords.new( 9, 9 ).map { |c| c.to_s }

  def Minesweeper.init( seed=nil )
    seed = rand 10000 if seed.nil?
    srand seed
    mines = []
    a = (0...81).to_a.sort_by { rand }
    10.times { |i| mines << Coord[a[i]/9,a[i]%9] }
    Position.new( MinesweeperBoard.new( 9, 9 ), mines, seed, @@init_ops.dup )
  end

  def Minesweeper.players
    [Player.one]
  end

  def Minesweeper.op?( position, op )
    position.unused_ops.include?( op.to_s )
  end

  def Minesweeper.ops( position )
    final?( position ) || position.unused_ops == [] ? nil : position.unused_ops
  end

  def Minesweeper.apply( position, op )
    c, pos = Coord[op], position.dup
    board, mines = pos.board, pos.mines

    revealed = board.reveal( c, mines )
    if revealed.any? { |rc| board[rc] == :b }
      pos.unused_ops.clear
    else
      pos.unused_ops -= revealed.map { |rc| rc.to_s }
    end

    pos
  end

  def Minesweeper.final?( position )
    Minesweeper.winner?( position ) || Minesweeper.loser?( position )
  end

  def Minesweeper.winner?( position, player=Player.one )
    position.unused_ops.size == 10
  end

  def Minesweeper.loser?( position, player=Player.one )
    position.unused_ops.empty?
  end

  def Minesweeper.draw?( position )
    false
  end
end

