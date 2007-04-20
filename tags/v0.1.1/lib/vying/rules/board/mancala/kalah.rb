require 'vying/rules'
require 'vying/board/mancala'

class Kalah < Rules

  info :name  => 'Kalah'

  attr_reader :board, :scoring_pits

  players [:one, :two]

  def initialize( seed=nil )
    super

    @board = MancalaBoard.new( 6, 2, 4 )
    @scoring_pits = { :one => 0, :two => 0 }
    @ops_cache = { :one => [:a1, :b1, :c1, :d1, :e1, :f1],
                   :two => [:a2, :b2, :c2, :d2, :e2, :f2] }
  end

  def op?( op, player=nil )
    valid = ops( player )
    valid && valid.include?( op )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    valid = @ops_cache[turn].select { |c| board[c] > 0 }
    valid.empty? ? false : valid
  end

  def apply!( op )
    h = op.x
    r = op.y

    # Sowing seeds

    seeds, board[op] = board[op], 0
    last = nil

    seeds.times do
      if r == 0 && h == 0
        r = 1
        h = -1
        if turn == :one
          scoring_pits[:one] += 1
          last = :one
          next
        end
      end

      if r == 1 && h == 5
        r = 0
        h = 6
        if turn == :two
          scoring_pits[:two] += 1
          last = :two
          next
        end
      end

      h -= 1 if r == 0 && h > 0
      h += 1 if r == 1 && h < 6
      
      board[h,r] += 1

      last = Coord[h,r]
    end

    # Capturing

    if last.kind_of?( Coord ) && board[last] == 1
      if last.y == 0 && turn == :one ||
         last.y == 1 && turn == :two
        scoring_pits[turn] += board[last.x,1]
        scoring_pits[turn] += board[last.x,0]
        board[last.x,1] = 0
        board[last.x,0] = 0
      end
    end

    # Extra turn?
      
    turn( :rotate ) if last != :one && last != :two

    # Clear remaining seeds if the game is over

    if final?
      players.each do |p|
        @ops_cache[p].each do |c|
          scoring_pits[p] += board[c]
          board[c] = 0
        end
      end
    end 

    self
  end

  def final?
    @ops_cache[turn].inject( 0 ) { |s,c| s + board[c] } == 0
  end

  def winner?( player )
    opp = player == :one ? :two : :one
    score( player ) > score( opp )
  end

  def loser?( player )
    opp = player == :one ? :two : :one
    score( player ) < score( opp )
  end

  def draw?
    score( :one ) == score( :two )
  end

  def score( player )
    scoring_pits[player]
  end

  def hash
    [board, scoring_pits, turn].hash
  end

end
