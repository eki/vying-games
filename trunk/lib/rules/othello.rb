require 'board/standard'
require 'game'

class OthelloBoard < Board
  def valid?( c, bp, directions=[:n,:s,:e,:w,:ne,:nw,:se,:sw] )
    return false if !self[c].nil?

    op = bp == :black ? :white : :black

    a = directions.zip( coords.neighbors_nil( c, directions ) )
    a.each do |d,nc|
      p = self[nc]
      next if p.nil? || p == bp

      i = nc
      while (i = coords.next( i, d ))
        p = self[i]
        return true if p == bp 
        break       if p.nil?
      end
    end

    false
  end

  def place( c, bp )
    op = bp == :black ? :white : :black

    directions = [:n,:s,:w,:e,:ne,:nw,:se,:sw]

    a = directions.zip( coords.neighbors_nil( c, directions ) )
    a.each do |d,nc|
      p = self[nc]
      next if p.nil? || p == bp

      bt = [nc]
      while (bt << coords.next( bt.last, d ))
        p = self[bt.last]
        break if p.nil?

        if p == bp
          bt.each { |bc| self[bc] = bp }
          break
        end
      end
    end

    self[c] = bp
  end
end

class Othello < Rules

  info :name    => 'Othello',
       :aliases => ['Reversi']

  attr_reader :board, :turn, :occupied, :frontier, :ops_cache

  players [:black, :white]

  def initialize( seed=nil )
    super

    @board = OthelloBoard.new( 8, 8 )
    board[3,3] = board[4,4] = :white
    board[3,4] = board[4,3] = :black

    @occupied = [Coord[3,3], Coord[4,4], Coord[3,4], Coord[4,3]]
    @frontier = occupied.map { |c| board.coords.neighbors( c ) }
    @frontier = @frontier.flatten.select { |c| board[c].nil? }.uniq

    @ops_cache = :ns

    @turn = players.dup
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    board.valid?( Coord[op], turn.now )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    return ops_cache if ops_cache != :ns
    a = frontier.select { |c| board.valid?( c, turn.now ) }.map { |c| c.to_s }
    ops_cache = (a == [] ? nil : a)
  end

  def apply!( op )
    c = Coord[op]
    board.place( c, turn.now )

    occupied << c

    @frontier += board.coords.neighbors( c ).select { |nc| board[nc].nil? }
    frontier.uniq!
    frontier.delete( c )

    turn.rotate!
    @ops_cache = :ns
    return self if ops

    turn.rotate!
    ops_cache = :ns

    self
  end

  def final?
    !ops
  end

  def winner?( player )
    opp = player == :black ? :white : :black
    board.count( player ) > board.count( opp )
  end

  def loser?( player )
    opp = player == :black ? :white : :black
    board.count( player ) < board.count( opp )
  end

  def draw?
    board.count( :white ) == board.count( :black )
  end
end

