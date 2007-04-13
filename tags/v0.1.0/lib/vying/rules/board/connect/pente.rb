require 'vying/rules'
require 'vying/board/connect6'

class Pente < Rules

  info :name      => 'Pente',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Pente>']

  attr_reader :board, :lastc, :lastp, :unused_ops, :captured

  players [:white, :black]

  @@init_ops = Coords.new( 19, 19 ).map { |c| c.to_s }

  def initialize( seed=nil )
    super

    @board = Connect6Board.new
    @lastc, @lastp = nil, :noone
    @unused_ops = @@init_ops.dup

    @captured = { :black => 0, :white => 0 }
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    unused_ops.include?( op.to_s )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    final? || unused_ops == [] ? nil : unused_ops
  end

  def apply!( op )
    c, p = Coord[op], turn
    board[c], @lastc, @lastp = p, c, p
    board.update_threats( c )
    @unused_ops.delete( c.to_s )

    # Custodian capture
    cap = []
    directions = [:n,:s,:e,:w,:ne,:nw,:se,:sw]
    a = directions.zip( board.coords.neighbors_nil( c, directions ) )
    a.each do |d,nc|
      next if board[nc].nil? || board[nc] == board[c]

      bt = [nc]
      while (bt << board.coords.next( bt.last, d ))
        break if board[bt.last].nil?
        break if bt.length < 3 && board[bt.last] == board[c]
        break if bt.length > 3

        if bt.length == 3 && board[bt.last] == board[c]
          bt.each { |bc| cap << bc unless board[bc] == board[c] }
          break
        end
      end
    end

    cap.each do |cc|  
      board[cc] = nil
      captured[turn] += 1
      @unused_ops << cc.to_s
    end

    turn( :rotate )
    self
  end

  def final?
    return false if lastc.nil?
    return true  if unused_ops.empty?

    return true if captured[:black] >= 10 || captured[:white] >= 10

    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } >= 4 ||
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } >= 4 ||
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } >= 4 ||
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } >= 4
  end

  def winner?( player )
    captured[player] >= 10 ||
    lastp == player &&
    (board.each_from( lastc, [:e,:w] ) { |p| p == player } >= 4 ||
     board.each_from( lastc, [:n,:s] ) { |p| p == player } >= 4 ||
     board.each_from( lastc, [:ne,:sw] ) { |p| p == player } >= 4 ||
     board.each_from( lastc, [:nw,:se] ) { |p| p == player } >= 4)
  end

  def loser?( player )
    !draw? && player != lastp
  end

  def draw?
    captured[:black] < 10 &&
    captured[:white] < 10 &&
    unused_ops.empty? &&
    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } < 4 &&
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } < 4 &&
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } < 4 &&
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } < 4
  end

  def score( player )
    captured[player]
  end

  def hash
    [board, captured, turn].hash
  end
end

