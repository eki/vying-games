# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying

  #  A Game represents the series of moves and positions that make up a game.
  #  It is heavily backed by a subclass of Rules.

  class Game

    # Core attributes

    attr_reader :rules, :options, :players, :history

    # Extended (unnecessary) attributes

    attr_reader :id, :unrated

    attr_accessor :time_limit

    alias game_id id

    # Create a game from the given Rules subclass, and an optional seed.  If
    # the game has random elements and a seed is not provided, one will be
    # created.  If you'd like to replay a game with random elements you must
    # provide the original seed.

    def initialize(rules, seed=nil, options={})
      if seed.class == Hash
        seed, options = nil, seed
      end

      @rules = Rules.find(rules)

      raise "#{rules} not supported!" if rules.nil?

      @history = History.new(rules, seed, options)
      @options = history.options.dup.freeze
      @players = history.first.players.map { |p| Player.new(p, self) }

      yield self if block_given?
    end

    # Create a game from the given history.  The history contains rules, seed,
    # options and a list of moves.  It doesn't contain any info about the Users
    # though.  Be careful to dup the history if it's already in use by another
    # Game.  This happens automatically if you pass a Game to Game.replay.

    def self.adopt_history(history)
      g = allocate
      g.instance_variable_set('@history', history)
      g.instance_variable_set('@rules', history.rules)
      g.instance_variable_set('@seed', history.seed)
      g.instance_variable_set('@options', history.options.dup.freeze)
      g.instance_variable_set('@players',
        history.first.players.map { |p| Player.new(p, g) })
      g
    end

    # Creates a new game instance by replaying from a results object.
    # The results object is a momento, containing only the minimal info
    # needed to recreate a full Game.  The results object must respond
    # to #rules, #seed, and #sequence.  It may also define #user( player )
    # that returns a user object for a player (it may return nil, or a
    # proxy object that responds to #to_user).  The results object may also
    # provide #id, #time_limit, and #last_move_at.
    #
    # As an alternative to the above, if the results object responds to
    # #history, Game.adopt_history will be used to setup the game.  Instead
    # of #rules, #seed, and #sequence.  This is the preferred method of
    # replaying a game.  The other methods (#user, #id, #time_limit) are still
    # used.  The #last_move_at method is only used when a history is
    # unavailable.

    def self.replay(results)
      if results.respond_to?(:history) && results.history
        h = results.class == Game ? results.history.dup : results.history
        g = Game.adopt_history(h)

      else

        if results.respond_to?(:options)
          g = Game.new(results.rules, results.seed,
                        (results.options || {}).dup)
        else
          g = Game.new(results.rules, results.seed)
        end

        g.history.no_timestamps = true
        g << results.sequence
        g.history.no_timestamps = false

      end

      results.rules.players.each do |p|
        if results.respond_to?(:user)
          u = results.user(p)
          g[p].user = u.to_user if u
        end
      end

      if results.respond_to?(:id)
        g.instance_variable_set('@id', results.id)
      end

      if results.respond_to?(:unrated)
        g.instance_variable_set('@unrated', results.unrated?)
      end

      if results.respond_to?(:time_limit)
        g.time_limit = results.time_limit
      end

      if results.respond_to?(:created_at)
        g.history.instance_variable_set('@created_at', results.created_at)
      end

      if results.respond_to?(:last_move_at)
        m = g.history.moves.last
        if m && m.at.nil?
          g.history.moves[-1] = m.stamp(results.last_move_at)
        end
        g.history.instance_variable_set('@last_move_at', results.last_move_at)
      end

      g
    end

    def notation
      # This is lazy loaded and not-cached to avoid creating a circular
      # reference between Game and Notation.
      if rules.notation
        Notation.find(self.rules.notation).new(self)
      else
        Notation.new(self)
      end
    end

    # Deprecated.  This is the equivalent of history.sequence, which is
    # also deprecated.  Use history.moves instead.

    def sequence
      history.sequence
    end

    # Note, this is different from history.moves.last.at in this sense:
    # sometimes a move will not leave an entry in history (for example, undo
    # which actually *removes* entries).  When this happens
    # history.last_move_at will be out of sync with the timestamp of the
    # last move in history.

    def last_move_at
      history.last_move_at
    end

    # When was this game created?  This is equivalent to calling
    # history.created_at.

    def created_at
      history.created_at
    end

    # Is this a timed game?  The other time related methods #time_remaining,
    # #expiration, #time_up?, and #timeout all return nil if timed? is false.

    def timed?
      !!time_limit
    end

    # How much time is remaining in this game?  This returns a float
    # representing the seconds remaining in the game.

    def time_remaining
      last_move_at + time_limit - Time.now if timed?
    end

    # When will this game expire?  Returns a Time object.  This value changes
    # as moves are made (or if the time_limit were to be changed.

    def expiration
      Time.at(last_move_at + time_limit) if timed?
    end

    # Has a player run out of time?  That is to say, the game is timed and
    # the time_remaining is now negative.  This returns the player name
    # (for example, :black or :white) for the player who is out of time.  If
    # time is not up, nil is returned.  Additionally, in games with sealed
    # (simultaneous) moves, nil is returned if more than one player has
    # run out of time.  That is, only a single player can run out of time.

    def time_up?
      if timed? && time_remaining < 0
        if (to = has_moves).length == 1
          to.first
        end
      end
    end

    # This method will end the game if it is timed and a player has run out
    # of time (according to #time_up?).
    #
    # This method is not called automatically.  That is, if a timed game is
    # started, #append will continue to accepted moves, even if a player has
    # run out of time.  So, for timed games, this method should always be called
    # prior to accepting moves.

    def timeout!
      if p = time_up?
        self << "time_exceeded_by_#{p}"
      end
    end

    # Missing method calls are passed on to the last position in the history,
    # if it responds to the call.

    def method_missing(method_id, *args)
      if history.last.respond_to?(method_id)
        history.last.send(method_id, *args)
      elsif rules.respond_to?(method_id)
        rules.send(method_id, *args)
      else
        super
      end
    end

    # We respond to any methods provided by the last position in history.

    def respond_to?(method_id, include_all=false)
      return false if method_id == :_dump

      # double !! to force false instead of nil
      super ||
        !!(history && history.last.respond_to?(method_id, include_all)) ||
        !!(rules && rules.respond_to?(method_id, include_all))
    end

    # Append a move to the Game's sequence of moves.  Whatever token is used
    # to represent a move will be converted to a String via #to_s.  It's more
    # common to use the more versatile Game#<< method.  However, append must
    # be used if the player argument cannot be inferred.  (Or, use Player#<<)

    def append(move, player=nil)
      m = wrap_move(move, player)

      if m && m.valid_for?(self, player)
        m.apply_to(self)

        if check_cycles? && !m.special?
          (0...(history.length - 1)).each do |i|
            history.last.cycle_found if history[i] == history.last
          end
        end

        return self
      end

      raise "'#{move}' not a valid move for '#{player}'"
    end

    # Append a list of moves to this game.  Calls Game#append for each move
    # in the given list.

    def append_list(moves)
      i = 0
      begin
        moves.each do |move|
          append(move)
          i += 1
        end
      rescue
        i.times { undo }
        raise
      end
      self
    end

    # The most versatile way of applying moves to this Game.  It will accept
    # an Enumerable list of moves, or a single move.

    def <<(moves)
      if moves.kind_of? Enumerable
        append_list(moves)
      else
        append(moves)
      end
    end

    # Turn the given move into a Move (or SpecialMove).  Does not attempt
    # to validate the given move, though it may have to in order to determine
    # the player if it's nil.

    def wrap_move(move, player=nil)
      return move                     if move.kind_of?(Move)
      return SpecialMove[move]        if SpecialMove[move]
      return Move.new(move, player) if player

      hm = has_moves

      return Move.new(move, hm.first) if hm.length == 1

      ps = hm.select { |p| move?(move, p) }

      if ps.length > 1
        raise "'#{move}' is ambiguous (available to #{ps.inspect})"
      end

      Move.new(move, ps.first) if ps.length == 1
    end

    # Undo a single move.  This returns [position, move, move_by] that have been
    # undone as an array.

    def undo
      history.undo
    end

    # Get the Player object for the given player name.  The User can be
    # obtained through Player#user and #user=.
    #
    # Example:
    #
    #   g = Game.new Othello
    #   g[:black]                          => <Player>
    #   g[:black].user = RandomBot.new     => <RandomBot>
    #   g[:black].user                     => <RandomBot>
    #
    # This can be useful when you want to use the convenience of Game#<< but
    # can't because the player must be specified (a game with sealed moves):
    #
    #   g = Game.new Footsteps
    #   g[:left] << 1
    #   g[:right] << 20
    #

    def [](p)
      players.find { |player| player.name == p }
    end

    # Assign a user via Player#user=.  This is deprecated.  Don't use it.

    def []=(p, u)
      puts "Warning: Don't use Game#[]=  !!!"
      self[p].user = u
    end

    # Get the User associated with the given player name.  This is equivalent
    # to:
    #
    #   g = Game.new Othello
    #   g[:black].user
    #

    def user(p)
      self[p].user
    end

    # Returns the users playing this game (in player order).

    def users
      player_names.map { |p| self[p].user }
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
        self[ps[0]].user, self[ps[1]].user = self[ps[1]].user, self[ps[0]].user
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
          next unless p.user && p.user.ready? && p.has_moves?

          position = history.last.censor(p.name)
          if p.user.accept_draw?(sequence, position, p.name)
            move = "draw_accepted_by_#{p.name}"
          else
            move = 'reject_draw'
          end

          append(move, p.name)
          return [move, p.name]
        end
      end

      # Accept or reject undo request
      if undo_requested?
        players.each do |p|
          next unless p.user && p.user.ready? && p.has_moves?

          position = history.last.censor(p.name)
          if p.user.accept_undo?(sequence, position, p.name)
            move = "undo_accepted_by_#{p.name}"
          else
            move = 'reject_undo'
          end

          append(move, p.name)
          return [move, p.name]
        end

        return self
      end

      player_names.each do |p|
        next unless self[p].user && self[p].user.ready?
        position, move = history.last.censor(p), nil

        # Handle draw offers
        if allow_draws_by_agreement? &&
           self[p].user.offer_draw?(sequence, position, p)
          move = "draw_offered_by_#{p}"
        end

        # Handle undo requests
        if self[p].user.request_undo?(sequence, position, p)
          move = "undo_requested_by_#{p}"
        end

        # Ask for resignation
        if self[p].user.resign?(sequence, position, p)
          move = "#{p}_resigns"
        end

        unless move.nil?
          append(move, p)
          return [move, p]
        end
      end

      has_moves.each do |p|
        next unless player_names.include?(p)
        next unless self[p].user && self[p].user.ready?
        position = history.last.censor(p)

        # Ask for an move
        move = self[p].user.select(sequence, position, p)
        if move?(move, p)
          append(move, p)
          return [move, p]
        else
          raise "#{self[p].username} attempted invalid move: #{move}"
        end
      end

      nil
    end

    # Repeatedly calls Game#step until the game is final.

    def play
      step until final?
      self
    end

    # Is the given player the winner of this game?  The results of this method
    # may be meaningless if Game#final? is not true.  This method accepts either
    # a player or a User.

    def winner?(player)
      history.last.winner?(who?(player))
    end

    # Is the given player the loser of this game?  The results of this method
    # may be meaningless if Game#final? is not true.  This method accepts either
    # a player or a User.

    def loser?(player)
      history.last.loser?(who?(player))
    end

    # Returns the score for the given player or user.  Shouldn't be used
    # without first checking #has_score?.  This method accepts either a
    # player or a User.

    def score(player)
      history.last.score(who?(player))
    end

    # Is the given move valid for the position this Game is currently in?  If
    # a player is provided, also verify that the move is valid for the given
    # player.  This method passes through to the last position in the game's
    # history, but accepts either or a player or a User.

    def move?(move, player=nil)
      history.last.move?(move, who?(player))
    end

    # Does the given player have any moves?  If no player is given all valid
    # moves are returned.  If given value is passed through #who?, so this
    # method accepts either a player or a User.

    def moves(player=nil)
      history.last.moves(who?(player))
    end

    # Returns true if the given player has any valid moves.

    def has_moves?(player)
      has_moves.include?(who?(player))
    end

    # You shouldn't rely on turn.  Use #has_moves instead.  Game#turn provides
    # has_moves.first anyway, not the underlying Position#turn.  And, unlike
    # Position#turn, Game#turn will return nil if Game#final? is true (due to
    # it being based on #has_moves which returns [] in that case).

    def turn
      has_moves.first
    end

    # Who can play the given move?

    def who_can_play?(move)
      has_moves.select { |p| move?(move, p) }
    end

    # Returns a list of valid special moves (resign, offer draw, and the like).

    def special_moves(player=nil)
      SpecialMove.generate_for(self, player)
    end

    # Is the given move a valid special move?

    def special_move?(move, player=nil)
      if move.kind_of?(Move) && move.special?
        move.valid_for?(self, player)
      elsif move = SpecialMove[move]
        move.valid_for?(self, player)
      end
    end

    # Who can make special moves?

    def has_special_moves
      player_names.reject { |p| special_moves(p).empty? }
    end

    # Can the given player make a special move?

    def has_special_moves?(player)
      !special_moves(player).empty?
    end

    # Have the players swap sides.  This is a special move is available if
    # the game supports the pie_rule.

    def swap
      if special_move?('swap')
        self[player_names.first].user, self[player_names.last].user =
          self[player_names.last].user, self[player_names.first].user
      end
    end

    # Did the players swap sides during the game (in accordance with the
    # pie_rule)?  Returns the index at which the swap took place or false
    # if the players didn't swap sides.

    def swapped?
      i = 0
      until i >= sequence.length
        return i     if history.sequence[i] == 'swap'
        return false if history.move_by[i]  != player_names.first
        i += 1
      end

      false
    end

    def accept_draw
      if draw_accepted?
        undo while draw_offered?
        history.append(SpecialMove['draw'])
      end
    end

    def reject_draw
      undo while history.last.draw_offered?
    end

    alias cancel_draw reject_draw

    def accept_undo
      if undo_accepted?
        undo while undo_requested?
        undo
      end
    end

    def reject_undo
      undo while history.last.undo_requested?
    end

    alias cancel_undo reject_undo

    # The user for the given player withdraws the game.  This is the method
    # that's executed for special moves like <player>_withdraws.

    def withdraw(player)
      self[player.to_sym].user = nil
    end

    # The user for the given player is kicked from the game.  This is the
    # method that's executed for special moves like kick_<player>.

    def kick(player)
      self[player.to_sym].user = nil
    end

    # Takes a User and returns which player he/she is.  If given a player
    # returns that player.

    def who?(user)
      return nil if user.nil?

      return user if user.class == Symbol

      player_names.find { |p| self[p].user == user }
    end

    # Is this a unrated game?  This is a wrapper around the :unrated attribute.
    # The only effect a unrated game has on this library is whether or not
    # the withdraw special move is available.  In an unrated game the users
    # can drop out by using withdraw.

    def unrated?
      unrated
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

    # Save this game to the specified format.  See Format.list for available
    # formats.

    def to_format(type)
      Vying.dump(self, type)
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
          s = players.join(' and ')
          s += ' played to a draw'
          s += ' (by agreement)' if draw_by_agreement?
          s
        else

          winners = players.select(&:winner?)
          losers  = players.select(&:loser?)

          ws = winners.join(' and ')
          ls = losers.join(' and ')

          s = "#{ws} defeated #{ls}"

          if has_score?
            ss = (winners + losers).map { |p| p.score.to_s }.join('-')
            s = "#{s}, #{ss}"
          end

          s += " (#{self[resigned_by].user} resigns)"   if resigned?
          s += ' (time exceeded)'                       if time_exceeded?
          s
        end
      else
        s = players.join(' vs ')

        if has_score?
          s = "#{s} (#{players.map(&:score).join('-')})"
        end

        s
      end
    end
  end
end

# For convenience make Game a top-level constant

Kernel.const_set('Game', Vying::Game) unless Kernel.const_defined?('Game')
