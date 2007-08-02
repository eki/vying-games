
class GameResults
  attr_reader :seed, :sequence, :user_map, :win_lose_draw, :scores, :check
  
  def initialize( game )
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

    i = rand(game.history.length-1)
    @check = "#{i},#{game.history[i].hash},#{game.history.last.hash}"
  end

  def rules
    Rules.find( @rules )
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

  def append( op )
    if op?( op )
      @history << apply( op )
      @sequence << op

      if history.last.class.check_cycles?
        history[0...(history.length-1)].each do |p|
          history.last.cycle_found if p == history.last
        end
      end

      return self
    end
    raise "'#{op}' not a valid operation"
  end

  def append_list( ops )
    i = 0
    begin
      ops.each { |op| append( op ); i += 1 }
    rescue
      i.times { undo }
    end
    self
  end

  def append_string( ops, regex=/,/ )
    append_list( ops.split( regex ) )
  end

  def <<( ops )
    if ops.kind_of? String
      return append_string( ops )
    elsif ops.kind_of? Enumerable
      return append_list( ops )
    else
      return append( ops )
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
    has_ops.each do |p|
      if players.include?( p )
        if user_map[p].ready?
          position = history.last.censor( p )
          op = user_map[p].select( sequence, position, p )
          if op?( op, p )
            self << op
          else
            raise "#{user_map[p].username} attempted invalid op: #{op}"
          end
        end
      elsif p == :random
        ops = history.last.ops
        self << ops[history.last.rng.rand(ops.size)]
      end
    end
    self
  end

  def play
    step until final?
    results
  end

  def results
    GameResults.new( self )
  end

  def Game.replay( results )
    g = Game.new( results.rules, results.seed )
    g << results.sequence
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

