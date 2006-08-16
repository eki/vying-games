require 'vying/rules'
require 'vying/board/standard'

class Amazons < Rules

  info :name      => "Amazons",
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Amazons_(game)>']

  attr_reader :board, :lastc, :wqs, :bqs, :ops_cache

  players [:white, :black]

  def initialize( seed=nil )
    super

    @board = Board.new( 10, 10 )

    @wqs = [Coord[0,3], Coord[3,0], Coord[6,0], Coord[9,3]]
    @bqs = [Coord[0,6], Coord[3,9], Coord[6,9], Coord[9,6]]
    
    wqs.each { |c| board[c] = :white }
    bqs.each { |c| board[c] = :black }

    @lastc = nil

    @ops_cache = :ns
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    return false unless op.to_s =~ /(\w\d+)(\w\d+)/

    sc = Coord[$1]
    ec = Coord[$2]

    queens = turn == :white ? wqs : bqs

    return false unless queens.include?( sc )
    return false unless d = sc.direction_to( ec )

    ic = sc
    while (ic = board.coords.next( ic, d ))
      return false if !board[ic].nil?
      break        if ic == ec
    end

    return true
  end

  def ops( player=nil )
    return [] unless player.nil? || has_ops.include?( player )
    return ops_cache if ops_cache != :ns

    a = []

    queens = turn == :white ? wqs : bqs

    if lastc.nil? || board[lastc] == :arrow
      queens.each do |c| 
        [:n,:e,:s,:w,:ne,:nw,:se,:sw].each do |d|
          ic = c
          while (ic = board.coords.next( ic, d ))
            board[ic].nil? ? a << "#{c}#{ic}" : break;
          end
        end
      end
    else
      [:n,:e,:s,:w,:ne,:nw,:se,:sw].each do |d|
        ic = lastc
        while (ic = board.coords.next( ic, d ))
          board[ic].nil? ? a << "#{lastc}#{ic}" : break;
        end
      end
    end

    ops_cache = a == [] ? nil : a
  end

  def apply!( op )
    op.to_s =~ /(\w\d+)(\w\d+)/
    sc = Coord[$1]
    ec = Coord[$2]

    if lastc.nil? || board[lastc] == :arrow
      board.move( sc, ec )
      queens = turn == :white ? wqs : bqs
      queens.delete( sc )
      queens << ec
    else
      board[ec] = :arrow
      turn( :rotate )
    end

    @lastc = ec
    @ops_cache = :ns

    self
  end

  def final?
    !ops
  end

  def winner?( player )
    turn != player
  end

  def loser?( player )
    turn == player
  end
end

