
class GameResults
  attr_reader :seed, :sequence, :win_lose_draw, :scores, :check

  def initialize( rules, seed, sequence, win_lose_draw, scores, check )
    @rules, @seed, @sequence, @win_lose_draw, @scores, @check =
      rules, seed, sequence, win_lose_draw, scores, check
  end
  
  def self.from_game( game )
    @rules = game.rules.to_snake_case
    @seed = game.respond_to?( :seed ) ? game.seed : nil
    @sequence = game.sequence

    @user_map = {}
    game.user_map.each { |k,v| @user_map[k] = [v.id, v.username] }

    @win_lose_draw = {}
    game.players.each do |p|
      @win_lose_draw[p] = :winner if game.winner?( p )
      @win_lose_draw[p] = :loser  if game.loser?( p )
      @win_lose_draw[p] = :draw   if game.draw?
    end

    @scores = {}
    if game.has_score?
      game.players.each do |p|
        @scores[p] = game.score( p )
      end
    end

    i = rand( game.history.length )
    @check = "#{i},#{game.history[i].hash},#{game.history.last.hash}"
  end

  def rules
    Rules.find( @rules )
  end

  def verify
    i, h1, h2 = check.split( /,/ ).map { |n| n.to_i }
    game = Game.replay( self )
    game.history[i].hash == h1 && game.history.last.hash == h2
  end
end

class Game
  attr_reader :history, :sequence, :user_map

  def initialize( rules, seed=nil )
    @rules, @history = rules.to_s, [rules.new( seed )]
    @sequence, @user_map = [], {}
    yield self if block_given?
  end

  # For serialization purposes we can't store the Rules class constant,
  # but it's what we actually want

  def rules
    Rules.find( @rules )
  end

  def method_missing( method_id, *args )
    # These extra checks that history is not nil are required for yaml-ization
    if history && history.last.respond_to?( method_id )
      history.last.send( method_id, *args )
    else
      super
    end
  end

  def respond_to?( method_id )
    # double !! to force false instead of nil
    super || !!(history && history.last.respond_to?( method_id ))
  end

  def append( move )
    move = move.to_s

    if move?( move )
      @history << apply( move )
      @sequence << move 

      if history.last.class.check_cycles?
        history[0...(history.length-1)].each do |p|
          history.last.cycle_found if p == history.last
        end
      end

      return self
    end
    raise "'#{move}' not a valid move"
  end

  def append_list( moves )
    i = 0
    begin
      moves.each { |move| append( move ); i += 1 }
    rescue
      i.times { undo }
      raise
    end
    self
  end

  def append_string( moves, regex=/,/ )
    append_list( moves.split( regex ) )
  end

  def <<( moves )
    if moves.kind_of? String
      return append_string( moves )
    elsif moves.kind_of? Enumerable
      return append_list( moves )
    else
      return append( moves )
    end
  end

  def undo
    [@history.pop,@sequence.pop]
  end

  def register_users( h )
    user_map.merge!( h )
  end

  def switch_sides
    if players.length == 2
      ps = players
      user_map[ps[0]], user_map[ps[1]] = user_map[ps[1]], user_map[ps[0]]
    end
    user_map
  end

  def step

    # Accept or reject offered draw
    if allow_draws_by_agreement? && offered_by = draw_offered_by
      accepted = user_map.all? do |p,u| 
        position = history.last.censor( p )
        p == offered_by || u.accept_draw?( sequence, position, p )
      end

      sequence.pop
      sequence << "draw" if accepted

      return self
    end

    has_moves.each do |p|
      if players.include?( p )
        if user_map[p].ready?
          position = history.last.censor( p )

          # Handle draw offers
          if allow_draws_by_agreement? && 
             user_map[p].offer_draw?( sequence, position, p )
            sequence << "draw_offered_by_#{p}"
            return self
          end

          # Ask for forfeit
          if user_map[p].forfeit?( sequence, position, p )
            sequence << "forfeit_by_#{p}"
            return self
          end

          # Ask for an move
          move = user_map[p].select( sequence, position, p )
          if move?( move, p )
            self << move 
          else
            raise "#{user_map[p].username} attempted invalid move: #{move}"
          end
        end
      elsif p == :random
        moves = history.last.moves
        self << moves[history.last.rng.rand(moves.size)]
      end
    end
    self
  end

  def play
    step until final?
    results
  end

  def seed
    history.last.respond_to?( :seed ) ? history.last.seed : nil
  end

  def final?
    forfeit? || draw_by_agreement? || history.last.final?
  end

  def winner?( player )
    (forfeit? && forfeit_by != player) || 
    (!draw_by_agreement? && 
     history.last.final? && history.last.winner?( player ))
  end

  def loser?( player )
    (forfeit? && forfeit_by == player) || 
    (!draw_by_agreement? && 
     history.last.final? && history.last.loser?( player ))
  end

  def draw?
    draw_by_agreement? || (history.last.final? && history.last.draw?)
  end

  def move?( move, player=nil )
    history.last.move?( move, player ) unless draw_by_agreement? || forfeit?
  end

  def moves( player=nil )
    draw_by_agreement? || forfeit? ? [] : history.last.moves( player )
  end

  def forfeit?
    !! forfeit_by
  end

  def forfeit_by
    if sequence.last =~ /^forfeit_by_(\w+)$/
      $1.intern
    end
  end

  def draw_by_agreement?
    sequence.last == "draw"
  end

  def draw_offered_by
    if sequence.last =~ /draw_offered_by_(\w+)/
      $1.intern
    end
  end

  def draw_offered?
    !! draw_offered_by
  end

  def results
    GameResults.from_game( self )
  end

  def Game.replay( results )
    special_moves = [/^forfeit_by_(\w+)$/, /draw_offered_by_(\w+)/,
                   /^draw$/]

    g = Game.new( results.rules, results.seed )

    s = results.sequence.dup

    if special_moves.any? { |sm| s.last =~ sm }
      s.pop
    end

    g << s
    g
  end

  def to_s
    history.last.to_s
  end

  def description
    if final?
      if draw?
        s = user_map.map { |p,u| "#{u} (#{p})" }.join( " and " )
        "#{s} played to a draw"
      else

        winners = players.select { |p| winner?( p ) }
        losers  = players.select { |p| loser?( p ) }

        ws = winners.map { |p| "#{user_map[p]} (#{p})" }.join( " and " )
        ls = losers.map  { |p| "#{user_map[p]} (#{p})" }.join( " and " )

        s = "#{ws} defeated #{ls}"

        if has_score?
          ss = (winners+losers).map { |p| "#{score(p)}" }.join( "-" )
          s = "#{s}, #{ss}"
        end

        s
      end
    else
      s = user_map.map { |p,u| "#{u} (#{p})" }.join( " vs " )

      if has_score?
        s = "#{s} (#{user_map.map { |p,u| score( p ) }.join( '-' )})"
      end

      s
    end
  end
end

