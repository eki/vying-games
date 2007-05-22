require 'vying/rules'
require 'vying/board/mancala'

class Oware < Rules

  info :name  => 'Oware'

  attr_reader :board, :scoring_pits, :annotation

  players [:one, :two]

  no_cycles

  def initialize( seed=nil )
    super

    @board = MancalaBoard.new( 6, 2, 4 )
    @annotation = MancalaBoard.new( 6, 2, "0" )

    @scoring_pits = { :one => 0, :two => 0 }
    @ops_cache = { :one => ['a1', 'b1', 'c1', 'd1', 'e1', 'f1'],
                   :two => ['a2', 'b2', 'c2', 'd2', 'e2', 'f2'] }
  end

  def op?( op, player=nil )
    valid = ops( player )
    valid && valid.include?( op.to_s )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )

    valid = @ops_cache[turn].select { |c| board[c] > 0 }

    # Check starvation rule
    opp = turn == :one ? :two : :one
    if @ops_cache[opp].all? { |c| board[c] == 0 }
      still_valid = []
      valid.each do |c|
        still_valid << c unless dup.apply!( c ).final?
      end
      valid = still_valid unless still_valid.empty?
    end

    valid.empty? ? false : valid
  end

  def apply!( op )
    # Reset annotation
    annotation[*annotation.coords] = "0"

    h = op.x
    r = op.y

    # Sowing seeds

    seeds, board[op] = board[op], 0
    last = nil

    annotation[op] = "e"

    while seeds > 0 
      if r == 0 && h == 0
        r = 1
        h = -1
      end

      if r == 1 && h == 5
        r = 0
        h = 6
      end

      h -= 1 if r == 0 && h > 0
      h += 1 if r == 1 && h < 6

      next if h == op.x && r == op.y
    
      seeds -= 1  
      board[h,r] += 1
      annotation[h,r] = (annotation[h,r].to_i + 1).to_s

      last = Coord[h,r]
    end

    # Capturing

    h, r = last.x, last.y
    opp_rank = turn == :one ? 1 : 0
    cap = []

    while r == opp_rank && (board[h,r] == 3 || board[h,r] == 2)
      cap << Coord[h,r]

      break if (h == 0 && r == 1) || (h == 5 && r == 0)

      h += 1 if r == 0 && h < 6
      h -= 1 if r == 1 && h > 0
    end

    opp = turn == :one ? :two : :one
    opp_empties = @ops_cache[opp].select { |c| board[c] == 0 }

    cap = [] if cap.length + opp_empties.length == 6   # Grand slam forfeit

    cap.each do |c|
      scoring_pits[turn] += board[c]
      board[c] = 0
      annotation[c] = "C"
    end

    turn( :rotate )

    # Clear remaining seeds if the game is over
    clear if final?

    self
  end

  def cycle_found
    clear
  end

  def final?
    !ops
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
    [board, score( :one ), score( :two ), turn].hash
  end

  def ==( o )
    puts "#{o.class}: #{o.inspect}"  if o.class != Oware
    turn == o.turn &&
    score( :one ) == o.score( :one ) &&
    score( :two ) == o.score( :two ) &&
    board == o.board
  end

  private
  def clear
    players.each do |p|
      @ops_cache[p].each do |c|
        scoring_pits[p] += board[c]
        board[c] = 0
        annotation[c] = "c" if annotation[c] == "0"
        annotation[c] = "C" if annotation[c] =~ /\d+/
      end
    end
  end

end
