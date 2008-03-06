# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

# GameResults is a memento of a Game.  Whereas Game stores every position
# as a part of it's history, GameResults stores only the seed and sequence
# of moves.  GameResults can be used to reconstruct a game by replaying the
# list of moves.

class GameResults
  attr_reader :seed, :sequence, :win_lose_draw, :scores, :check

  # Create GameResults by very simply assigning the given values to
  # their respective properties.  It's more likely that you'll get
  # a GameResults object by calling Game#results

  def initialize( rules, seed, sequence, win_lose_draw, scores, check )
    @rules, @seed, @sequence, @win_lose_draw, @scores, @check =
      rules, seed, sequence, win_lose_draw, scores, check
  end

  # Create a GameResults object from a Game.  This is used by Game#results,
  # the preferred method for getting a GameResults object.
  
  def self.from_game( game )
    @rules = game.rules.to_snake_case
    @seed = game.respond_to?( :seed ) ? game.seed : nil
    @sequence = game.sequence

    @user_map = {}
    game.players.each do |p| 
      @user_map[p] = [game[p].id, game[p].username]
    end

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

  # Returns the Rules subclass for the Game that this is the GameResults of.
  # The GameResults @rules instance variable actually stores a string, this
  # method attempts to turn it into a class via Rules.find.

  def rules
    Rules.find( @rules )
  end

  # Checks the GameResults checksum.  If the code replaying the game is
  # consistent with the code that was used to originally play the game,
  # then the check's should match.

  def verify
    i, h1, h2 = check.split( /,/ ).map { |n| n.to_i }
    game = Game.replay( self )
    game.history[i].hash == h1 && game.history.last.hash == h2
  end
end

#  History component of a Game.  This is the sequence and position cache.
#  It behaves much like an array but doesn't write out every position when
#  being serialized (and thus needs to be able to recreate positions based
#  on the sequence when necessary.

class History
  include Enumerable

  attr_reader :sequence, :positions

  SPECIAL_MOVES = [/^draw_offered_by_/,
                   /^forfeit_by_/,
                   /^time_exceeded_by/,
                   /^draw$/]

  # Takes the initial position and initializes the sequence and positions
  # arrays.

  def initialize( start )
    @sequence, @positions = [], [start]
  end

  # Fetch a position from history.

  def []( i )
    return nil          if i > length
    return positions[i] if positions[i]

    # Need to recreate a missing position
    j = i
    until positions[j]
      j -= 1
    end

    until j == i
      positions[j+1] = positions[j].apply( sequence[j] )
      j += 1
    end

    positions[i]
  end

  # Fetch the first position from history.

  def first
    positions[0]
  end

  # Fetch the last position from history.

  def last
    positions[length-1] # Use [] -- positions could be missing
  end

  # Is the last move special?

  def last_special?
    SPECIAL_MOVES.any? { |p| sequence.last =~ p }
  end

  # How many positions are in this history?

  def length
    if last_special?
      sequence.length
    else
      sequence.length + 1
    end
  end

  # Add a new position to history.  The given move is applied to the last
  # position in history and the new position is appended to the end of the
  # history.

  def <<( move )
    positions << positions.last.apply( move )
    sequence << move
    self
  end

  # Iterate over the positions in this history.

  def each
    sequence.length.times { |i| yield self[i] }
  end

  # Compare History objects.

  def eql?( o )
    positions.first == o.positions.first && sequence == o.sequence
  end

  # Compare History objects.

  def ==( o )
    eql? o
  end

  # For efficiency's sake don't dump the entire positions array

  def _dump( depth=-1 )
    ps = positions

    if length > 6
      ps = [nil] * length
      ps[0] = positions.first
      r = ( (ps.length - 6)..(ps.length - 1) )
      ps[r] = positions[r]
    end

    Marshal.dump( [sequence, ps] )
  end

  # Load mashalled data.

  def self._load( s )
    s, p = Marshal.load( s )
    h = self.allocate
    h.instance_variable_set( "@sequence", s )
    h.instance_variable_set( "@positions", p )
    h
  end

end

#  A Game represents the series of moves and positions that make up a game.
#  It is heavily backed by a subclass of Rules.

class Game
  attr_reader :history

  # Create a game from the given Rules subclass, and an optional seed.  If
  # the game has random elements and a seed is not provided, one will be 
  # created.  If you'd like to replay a game with random elements you must
  # provide the original seed.

  def initialize( rules, seed=nil )
    @rules, @history = rules.to_s, History.new( rules.new( seed ) )
    @user_map = {}
    yield self if block_given?
  end

  def sequence
    history.sequence
  end

  # Returns the Rules subclass that this Game is based on.  For serialization
  # purposes the @rules instance variable actually stores a string, but this
  # returns the class (which is more useful).

  def rules
    Rules.find( @rules )
  end

  # Missing method calls are passed on to the last position in the history,
  # if it responds to the call.

  def method_missing( method_id, *args )
    # These extra checks that history is not nil are required for yaml-ization
    if history && history.last.respond_to?( method_id )
      history.last.send( method_id, *args )
    else
      super
    end
  end

  # We respond to any methods provided by the last position in history.

  def respond_to?( method_id )
    # double !! to force false instead of nil
    super || !!(history && history.last.respond_to?( method_id ))
  end

  # Append a move to the Game's sequence of moves.  Whatever token is used
  # to represent a move will be converted to a String via #to_s.  It's more
  # common to use the more versatile Game#<< method.

  def append( move )
    special_moves = [/^forfeit_by_(\w+)$/, /draw_offered_by_(\w+)/,
                   /^draw$/, /^time_exceeded_by_(\w+)$/]

    move = move.to_s

    if move?( move )
      history << move

      if history.last.class.check_cycles?
        (0...(history.length-1)).each do |i|
          history.last.cycle_found if history[i] == history.last
        end
      end

      return self

    elsif special_moves.any? { |sm| move =~ sm }

      history.sequence << move
      return self

    end
    raise "'#{move}' not a valid move"
  end

  # Append a list of moves to this game.  Calls Game#append for each move
  # in the given list.

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

  # Splits a string on the given regex and then feeds it to Game#append_list.

  def append_string( moves, regex=/,/ )
    append_list( moves.split( regex ) )
  end

  # The most versatile way of applying moves to this Game.  It will accept
  # moves as a comma separated String, an Enumerable list of moves, or a 
  # single move.

  def <<( moves )
    if moves.kind_of? String
      return append_string( moves )
    elsif moves.kind_of? Enumerable
      return append_list( moves )
    else
      return append( moves )
    end
  end

  # Undo a single move.  This returns [position, move] that have been undone
  # as an array.

  def undo
    if history.last_special?
      [history.last, history.sequence.pop]
    else
      [history.positions.pop, history.sequence.pop]
    end
  end

  # Accepts a hash mapping players to users.  The players should match up to
  # the players returned by #players.  The users should be an instance
  # of User or one of it's subclasses, but should implement the AI::Bot 
  # interface if you intend to use Game#step or Game#play.

  def register_users( h )
    @user_map.merge!( h )
  end

  # Get the User playing as the given player.
  #
  # Example:
  #
  #   g = Game.new Othello
  #   g[:black]                     => nil
  #   g[:black] = RandomBot.new     => <RandomBot>
  #   g[:black]                     => <RandomBot>
  #

  def []( p )
    @user_map[p]
  end

  # Assign an instance of the User playing as the given player.
  #
  # Example:
  #
  #   g = Game.new Othello
  #   g[:black] = RandomBot.new
  #   g[:white] = Human.new
  #

  def []=( p, u )
    @user_map[p] = u
  end

  def users
    @user_map.values
  end

  # If this is a 2 player game, #switch_sides will swap the registered users.

  def switch_sides
    if players.length == 2
      ps = players
      @user_map[ps[0]], @user_map[ps[1]] = @user_map[ps[1]], @user_map[ps[0]]
    end
    self
  end

  # Ask the registered users for one move, and apply it.  The registered
  # user must respond to methods like:
  #
  #   *  AI::Bot#offer_draw?
  #   *  AI::Bot#accept_draw?
  #   *  AI::Bot#forfeit?
  #   *  AI::Bot#select
  #
  # If these methods aren't implemented (select in particular) by the
  # registered user, Game#step and Game#play cannot be used.

  def step

    # Accept or reject offered draw
    if allow_draws_by_agreement? && offered_by = draw_offered_by
      accepted = @user_map.all? do |p,u| 
        position = history.last.censor( p )
        p == offered_by || u.accept_draw?( sequence, position, p )
      end

      sequence.pop
      sequence << "draw" if accepted

      return self
    end

    has_moves.each do |p|
      if players.include?( p )
        if @user_map[p].ready?
          position = history.last.censor( p )

          # Handle draw offers
          if allow_draws_by_agreement? && 
             @user_map[p].offer_draw?( sequence, position, p )
            sequence << "draw_offered_by_#{p}"
            return self
          end

          # Ask for forfeit
          if @user_map[p].forfeit?( sequence, position, p )
            sequence << "forfeit_by_#{p}"
            return self
          end

          # Ask for an move
          move = @user_map[p].select( sequence, position, p )
          if move?( move, p )
            self << move 
          else
            raise "#{@user_map[p].username} attempted invalid move: #{move}"
          end
        end
      elsif p == :random
        moves = history.last.moves
        self << moves[history.last.rng.rand(moves.size)]
      end
    end
    self
  end

  # Repeatedly calls Game#step until the game is final.

  def play
    step until final?
    results
  end

  # Returns this Game's seed.  If this game's rules don't allow for any random
  # elements the seed will be nil.

  def seed
    history.last.respond_to?( :seed ) ? history.last.seed : nil
  end

  # Is this game over?.  If so, there are now winners and losers, and so 
  # forth.  A Game may be final even if the rules state that the last position
  # in its history is *not* final.  This can happen if the Game has ended in
  # a forfeit or a negotiated draw or a player exceeding their alloted time.

  def final?
    forfeit? || draw_by_agreement? || time_exceeded? ||  history.last.final?
  end

  # Is the given player the winner of this game?  The results of this method
  # may be meaningless if Game#final? is not true.

  def winner?( player )
    player = who?( player )

    (forfeit? && forfeit_by != player) || 
    (time_exceeded? && time_exceeded_by != player) ||
    (!draw_by_agreement? && 
     history.last.final? && history.last.winner?( player ))
  end

  # Is the given player the loser of this game?  The results of this method
  # may be meaningless if Game#final? is not true.

  def loser?( player )
    player = who?( player )

    (forfeit? && forfeit_by == player) || 
    (time_exceeded? && time_exceeded_by == player) ||
    (!draw_by_agreement? && 
     history.last.final? && history.last.loser?( player ))
  end

  # Has this game ended in a draw?  The results of this method may be 
  # meaningless if Game#final? is not true.

  def draw?
    draw_by_agreement? || (history.last.final? && history.last.draw?)
  end

  # Returns the score for the given player or user.  Shouldn't be used
  # without first checking #has_score?.

  def score( player )
    history.last.score( who?( player ) )
  end

  # Is the given move valid for the position this Game is currently in?  If
  # a player is provided, also verify that the move is valid for the given
  # player.

  def move?( move, player=nil )
    unless draw_by_agreement? || draw_offered? || forfeit? || time_exceeded?
      history.last.move?( move, who?( player ) )
    end
  end

  # Return a list of all valid moves for the last position in this Game's 
  # history.  If a player is given, filter this list to include only valid
  # moves for that player.

  def moves( player=nil )
    if draw_by_agreement? || draw_offered? || forfeit? || time_exceeded?
      [] 
    else
      history.last.moves( who?( player ) )
    end
  end

  # Returns a list of which players have valid moves for the last position
  # in history.

  def has_moves
    if forfeit? || time_exceeded?
      []
    elsif draw_offered?
      players - [draw_offered_by]
    else
      history.last.has_moves
    end
  end

  # Returns true if the given player has any valid moves.

  def has_moves?( player )
    has_moves.include?( who?( player ) )
  end

  # Takes a User and returns which player he/she is.  If given a player
  # returns that player.

  def who?( user )
    return nil if user.nil?

    return user if user.class == Symbol

    players.find { |p| self[p] == user }
  end

  # Has this game ended in a forfeit?

  def forfeit?
    !! forfeit_by
  end

  # If this game has ended in a forfeit, which player resigned?

  def forfeit_by
    if sequence.last =~ /^forfeit_by_(\w+)$/
      $1.intern
    end
  end

  # Has this game ended in a draw by the agreement of the players?

  def draw_by_agreement?
    sequence.last == "draw"
  end

  # If a draw has been offered, which player offered it?

  def draw_offered_by
    if sequence.last =~ /draw_offered_by_(\w+)/
      $1.intern
    end
  end

  # Has the given player offered a draw?

  def draw_offered_by?( player )
    draw_offered_by == player
  end

  # Has a draw been offered?

  def draw_offered?
    !! draw_offered_by
  end

  # Has a player exceeded the time limit?

  def time_exceeded?
    !! time_exceeded_by
  end

  # Which player exceeded the time limit?

  def time_exceeded_by
    if sequence.last =~ /time_exceeded_by_(\w+)/
      $1.intern
    end
  end

  # Returns a GameResults momento for this Game.

  def results
    GameResults.from_game( self )
  end

  # Creates a new game instance by replaying the a GameResults object.

  def Game.replay( results )
    g = Game.new( results.rules, results.seed )
    g << results.sequence
    g
  end

  # The string representation of a Game is the string representation of the
  # last position in its history.

  def to_s
    history.last.to_s
  end

  # This is being defined so that we don't pass through to Rules#to_yaml_type.
  # And, because #name get's passed to Rules#name which overrides Class#name
  # which YAML normally depends on.

  def to_yaml_type
    "!ruby/object:#{self.class}"
  end

  # Provides a string describing the matchup.  For example:
  #
  #   eki (black) defeated SiriusBot (white), 34-30
  #
  # This depends on the user object's to_s method returning something 
  # reasonable like a username.

  def description
    if final?
      if draw?
        s = rules.players.map { |p| "#{@user_map[p]} (#{p})" }.join( " and " )
        s += " played to a draw"
        s += " (by agreement)" if draw_by_agreement?
        s
      else

        winners = players.select { |p| winner?( p ) }
        losers  = players.select { |p| loser?( p ) }

        ws = winners.map { |p| "#{@user_map[p]} (#{p})" }.join( " and " )
        ls = losers.map  { |p| "#{@user_map[p]} (#{p})" }.join( " and " )

        s = "#{ws} defeated #{ls}"

        if has_score?
          ss = (winners+losers).map { |p| "#{score(p)}" }.join( "-" )
          s = "#{s}, #{ss}"
        end

        s += " (forfeit by #{self[forfeit_by]})" if forfeit?
        s += " (time exceeded)"                  if time_exceeded?
        s
      end
    else
      s = rules.players.map { |p| "#{@user_map[p]} (#{p})" }.join( " vs " )

      if has_score?
        s = "#{s} (#{rules.players.map { |p| score( p ) }.join( '-' )})"
      end

      s
    end
  end
end

