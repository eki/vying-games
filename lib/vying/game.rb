# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

#  A Game represents the series of moves and positions that make up a game.
#  It is heavily backed by a subclass of Rules.

class Game

  # Core attributes

  attr_reader :rules, :options, :players, :history, :notation

  # Extended (unnecessary) attributes

  attr_reader :id, :unrated, :time_limit, :last_move_at

  alias_method :game_id, :id

  # Create a game from the given Rules subclass, and an optional seed.  If
  # the game has random elements and a seed is not provided, one will be 
  # created.  If you'd like to replay a game with random elements you must
  # provide the original seed.

  def initialize( rules, seed=nil, options={} )
    if seed.class == Hash
      seed, options = nil, seed
    end

    @rules = Rules.find( rules )

    raise "#{rules} not supported!" if rules.nil?

    #@rules = rules.class_name

    @history = History.new( rules.new( seed, options ) )
    @options = history.first.options.dup.freeze
    @players = history.first.players.map { |p| Player.new( p, self ) }

    if rules.notation
      @notation = Notation.find( self.rules.notation ).new( self )
    else
      @notation = Notation.new( self )
    end

    yield self if block_given?
  end

  def sequence
    history.sequence
  end

  # Missing method calls are passed on to the last position in the history,
  # if it responds to the call.

  def method_missing( method_id, *args )
    # These extra checks that history is not nil are required for yaml-ization
    if history && history.last.respond_to?( method_id )
      history.last.send( method_id, *args )
    elsif rules && rules.respond_to?( method_id )
      rules.send( method_id, *args )
    else
      super
    end
  end

  # We respond to any methods provided by the last position in history.

  def respond_to?( method_id )
    return false if method_id == :_dump

    # double !! to force false instead of nil
    super || !!(history && history.last.respond_to?( method_id )) ||
             !!(rules && rules.respond_to?( method_id ))
  end

  # Append a move to the Game's sequence of moves.  Whatever token is used
  # to represent a move will be converted to a String via #to_s.  It's more
  # common to use the more versatile Game#<< method.  However, append must
  # be used if the player argument cannot be inferred.  (Or, use Player#<<)

  def append( move, player=nil )
    move = move.to_s

    # If player is nil, try to initialize it

    if player.nil? 
      if has_moves == [:random]
        player = :random
      else
        ps = player_names.select do |p| 
          special_move?( move, p ) || move?( move, p )
        end

        if ps.length == 1
          player = ps.first
        elsif ps.length > 1
          raise "'#{move}' is ambiguous (available to #{ps.inspect})"
        end
      end
    end

    if player.nil? && ! special_move?( move )
      raise "Unable to determine player for move '#{move}'"
    end

    if move?( move, player )
      history.append( move, player )

      if check_cycles?
        (0...(history.length-1)).each do |i|
          history.last.cycle_found if history[i] == history.last
        end
      end

      return self

    elsif special_move?( move, player )

      msym = move.intern
      if respond_to?( msym )
        send( msym )

      elsif player_names.any? { |p| move =~ /^(#{p})_withdraws$/ }
        withdraw( $1.intern )

      elsif player_names.any? { |p| move =~ /^kick_(#{p})$/ }
        kick( $1.intern )

      else
        history.append( move, player )

        if history.last.draw_offered? && history.last.has_moves.empty?
          accept_draw
        elsif history.last.undo_requested? && history.last.has_moves.empty?
          accept_undo
        end
      end

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

  # Undo a single move.  This returns [position, move, move_by] that have been
  # undone as an array.

  def undo
    [history.sequence.pop, history.move_by.pop, history.positions.pop]
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
    players.find { |player| player.name == p }.user
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
    player = players.find { |player| player.name == p }
    player.user = u
  end

  # Alias of #[]

  def user( p )
    self[p]
  end

  # Returns the users playing this game (in player order).

  def users
    player_names.map { |p| self[p] }
  end

  # returns the names of the players for this game.  This is the equivalent
  # of Rules#players (not Rules.players).

  def player_names
    history.first.players
  end

  # If this is a 2 player game, #switch_sides will swap the registered users.

  def switch_sides
    if player_names.length == 2
      ps = player_names
      self[ps[0]], self[ps[1]] = self[ps[1]], self[ps[0]]
    end
    self
  end

  # Ask the registered users for one move, and apply it.  The registered
  # user must respond to methods like:
  #
  #   *  AI::Bot#offer_draw?
  #   *  AI::Bot#accept_draw?
  #   *  AI::Bot#resign?
  #   *  AI::Bot#select
  #
  # If these methods aren't implemented (select in particular) by the
  # registered user, Game#step and Game#play cannot be used.
  #
  # Returns an array of the [move, player_name] that were taken.  If no move
  # was made returns nil (this will only occur if you call #step on a #final?
  # game or no players are #ready?.

  def step

    # Accept or reject offered draw
    if allow_draws_by_agreement? && draw_offered?
      players.each do |p| 
        if p.user && p.user.ready? && p.has_moves?
          
          position = history.last.censor( p.name )
          if p.user.accept_draw?( sequence, position, p.name )
            move = "draw_accepted_by_#{p.name}"
          else
            move = "reject_draw"
          end

          self << move
          return [move, p.name]
        end
      end
    end

    # Accept or reject undo request 
    if undo_requested?
      players.each do |p| 
        if p.user && p.user.ready? && p.has_moves?
          
          position = history.last.censor( p.name )
          if p.user.accept_undo?( sequence, position, p.name )
            move = "undo_accepted_by_#{p.name}"
          else
            move = "reject_undo"
          end

          self << move
          return [move, p.name]
        end
      end

      return self
    end


    player_names.each do |p|
      if self[p].ready?
        position, move = history.last.censor( p ), nil

        # Handle draw offers
        if allow_draws_by_agreement? && 
           self[p].offer_draw?( sequence, position, p )
          move = "draw_offered_by_#{p}"
        end

        # Handle undo requests 
        if self[p].request_undo?( sequence, position, p )
          move = "undo_requested_by_#{p}"
        end

        # Ask for resignation
        if self[p].resign?( sequence, position, p )
          move = "#{p}_resigns"
        end

        unless move.nil?
          history.append( move, p )
          return [move, p]
        end
      end
    end

    has_moves.each do |p|
      if player_names.include?( p )
        if self[p].ready?
          position = history.last.censor( p )

          # Ask for an move
          move = self[p].select( sequence, position, p )
          if move?( move, p )
            self << move 
            return [move, p]
          else
            raise "#{self[p].username} attempted invalid move: #{move}"
          end
        end
      elsif p == :random
        moves = history.last.moves
        move = moves[history.last.rng.rand(moves.size)]
        self << move
        return [move, :random]
      end
    end

    nil
  end

  # Repeatedly calls Game#step until the game is final.

  def play
    step until final?
    self
  end

  # Returns this Game's seed.  If this game's rules don't allow for any random
  # elements the seed will be nil.

  def seed
    history.last.respond_to?( :seed ) ? history.last.seed : nil
  end

  # Is the given player the winner of this game?  The results of this method
  # may be meaningless if Game#final? is not true.  This method accepts either
  # a player or a User.

  def winner?( player )
    history.last.winner?( who?( player ) )
  end

  # Is the given player the loser of this game?  The results of this method
  # may be meaningless if Game#final? is not true.  This method accepts either
  # a player or a User.

  def loser?( player )
    history.last.loser?( who?( player ) )
  end

  # Returns the score for the given player or user.  Shouldn't be used
  # without first checking #has_score?.  This method accepts either a
  # player or a User.

  def score( player )
    history.last.score( who?( player ) )
  end

  # Is the given move valid for the position this Game is currently in?  If
  # a player is provided, also verify that the move is valid for the given
  # player.  This method passes through to the last position in the game's
  # history, but accepts either or a player or a User.

  def move?( move, player=nil )
    history.last.move?( move, who?( player ) )
  end

  # Returns true if the given player has any valid moves.

  def has_moves?( player )
    has_moves.include?( who?( player ) )
  end

  # You shouldn't rely on turn.  Use #has_moves instead.  Game#turn provides
  # has_moves.first anyway, not the underlying Position#turn.

  def turn
    has_moves.first || history.last.turn
  end

  # Who can play the given move?

  def who_can_play?( move )
    has_moves.select { |p| move?( move, p ) }
  end

  # Returns a list of special moves (resign, offer draw, and the like).

  def special_moves( player=nil )
    return [] if final?

    moves = []

    if pie_rule? && sequence.length >= 1 && 
       (player.nil? || player != player_names.first) &&
       ! has_moves?( player_names.first ) &&
       history.move_by.all? { |p| p == player_names.first }
      moves << "swap"
    end

    if draw_offered?
      return [] if draw_offered_by?( player )
      return [] if draw_accepted_by?( player )

      unless player.nil? || draw_accepted_by?( player )
        return ["draw_accepted_by_#{player}", "reject_draw"]
      end

      player_names.each do |p|
        unless draw_offered_by?( p ) || draw_accepted_by?( p )
          moves << "draw_accepted_by_#{p}"
        end
      end

      moves << "reject_draw"

    elsif undo_requested?
      return [] if undo_requested_by?( player )
      return [] if undo_accepted_by?( player )

      unless player.nil? || undo_accepted_by?( player )
        return ["undo_accepted_by_#{player}", "reject_undo"]
      end

      player_names.each do |p|
        unless undo_requested_by?( p ) || undo_accepted_by?( p )
          moves << "undo_accepted_by_#{p}"
        end
      end

      moves << "reject_undo"

    else
      normal_undo = false

      player_names.each do |p|
        if history.length > 1
          last = history.last
          next_to_last = history[history.length - 2]
          if last.has_moves?( p ) && next_to_last.has_moves?( p )
            normal_undo = true
            moves << "undo"  if player.nil? || p == player
          end
        end
      end

      player_names.each do |p|
        if player.nil? || p == player
          moves << "undo_requested_by_#{p}" unless normal_undo ||
                                                   sequence.length == 0
          if player_names.length == 2
            moves << "#{p}_resigns"
            moves << "draw_offered_by_#{p}" if allow_draws_by_agreement?
          end
        end
      end

    end

    if player.nil?
      moves << "draw" if allow_draws_by_agreement?
      player_names.each do |p|
        moves << "time_exceeded_by_#{p}"
      end
    end

    if unrated?
      if player.nil?
        players.each do |p|
          moves << "#{p.name}_withdraws" if p.user
        end
        players.each do |p|
          moves << "kick_#{p.name}" if p.user
        end
      else
        moves << "#{player}_withdraws" if self[player]
      end
    end

    if unrated?
      players.each do |p|
        if p.user && (player.nil? || (p.name != player && self[player]))
          moves << "kick_#{p.name}"
        end
      end
    end

    moves
  end

  # Is the given move a valid special move?

  def special_move?( move, player=nil )
    special_moves( player ).include?( move )
  end

  # Who can make special moves?

  def has_special_moves
    player_names.select { |p| ! special_moves( p ).empty? }    
  end

  # Can the given player make a special move?

  def has_special_moves?( player )
    ! special_moves( player ).empty?
  end

  def swap
    if special_move?( "swap" )
      self[player_names.first], self[player_names.last] = 
        self[player_names.last], self[player_names.first]

      history.append( "swap", has_moves.first )
    end
  end

  def accept_draw
    undo while history.last.draw_offered?
    history.append( "draw", nil )
  end

  def reject_draw
    undo while history.last.draw_offered?
  end

  def accept_undo
    undo while history.last.undo_requested?
    undo
  end

  def reject_undo
    undo while history.last.undo_requested?
  end

  # The user for the given player withdraws the game.  This is the method that's
  # executed for special moves like <player>_withdraws.

  def withdraw( player )
    self[player] = nil
  end

  # The user for the given player is kicked from the game.  This is the method
  # that's executed for special moves like kick_<player>.

  def kick( player )
    self[player] = nil
  end

  # Takes a User and returns which player he/she is.  If given a player
  # returns that player.

  def who?( user )
    return nil if user.nil?

    return user if user.class == Symbol

    player_names.find { |p| self[p] == user }
  end

  # Is this a unrated game?  This is a wrapper around the :unrated attribute.
  # The only effect a unrated game has on this library is whether or not
  # the withdraw special move is available.  In an unrated game the users
  # can drop out by using withdraw.

  def unrated?
    unrated
  end

  # Creates a new game instance by replaying from a results object.
  # The results object is a momento, containing only the minimal info
  # needed to recreate a full Game.  The results object must respond
  # to #rules, #seed, and #sequence.  It may also define #user( player )
  # that returns a user object for a player (it may return nil, or a
  # proxy object that responds to #to_user).  The results object may also
  # provide #id, #time_limit, and #last_move_at.

  def Game.replay( results )
    if results.respond_to?( :options )
      g = Game.new( results.rules, results.seed, (results.options || {}).dup )
    else
      g = Game.new( results.rules, results.seed )
    end

    g << results.sequence

    results.rules.players.each do |p|
      if results.respond_to?( :user )
        u = results.user( p )
        g[p] = u.to_user if u
      end
    end

    if results.respond_to?( :id )
      g.instance_variable_set( "@id", results.id )
    end

    if results.respond_to?( :unrated )
      g.instance_variable_set( "@unrated", results.unrated? )
    end

    if results.respond_to?( :time_limit )
      g.instance_variable_set( "@time_limit", results.time_limit )
    end
    
    if results.respond_to?( :last_move_at )
      g.instance_variable_set( "@last_move_at", results.last_move_at )
    end
    
    g
  end

  # The string representation of a Game is the string representation of the
  # last position in its history.

  def to_s
    history.last.to_s
  end

  # Abbreviated inspect string for this game.
 
  def inspect
    "#<Game #{id} rules: '#{rules}' description: '#{description}'>"
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
        s = player_names.map { |p| "#{self[p] || '?'} (#{p})" }.join( " and " )
        s += " played to a draw"
        s += " (by agreement)" if draw_by_agreement?
        s
      else

        winners = player_names.select { |p| winner?( p ) }
        losers  = player_names.select { |p| loser?( p ) }

        ws = winners.map { |p| "#{self[p] || '?'} (#{p})" }.join( " and " )
        ls = losers.map  { |p| "#{self[p] || '?'} (#{p})" }.join( " and " )

        s = "#{ws} defeated #{ls}"

        if has_score?
          ss = (winners+losers).map { |p| "#{score(p)}" }.join( "-" )
          s = "#{s}, #{ss}"
        end

        s += " (#{self[resigned_by]} resigns)"   if resigned?
        s += " (time exceeded)"                  if time_exceeded?
        s
      end
    else
      s = player_names.map { |p| "#{self[p] || '?'} (#{p})" }.join( " vs " )

      if has_score?
        s = "#{s} (#{player_names.map { |p| score( p ) }.join( '-' )})"
      end

      s
    end
  end
end

