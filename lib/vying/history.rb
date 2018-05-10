# frozen_string_literal: true

# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying

  #  History component of a Game.  This is the sequence and position cache.
  #  It behaves much like an array but doesn't write out every position when
  #  being serialized (and thus needs to be able to recreate positions based
  #  on the move history as necessary.

  class History
    include Enumerable

    attr_reader :rules, :seed, :options, :moves, :last_move_at, :created_at

    attr_accessor :no_timestamps

    # Takes the ingredients for the first position (rules, seed, options) and
    # initializes a history.

    def initialize(rules, seed, options)
      @rules = rules
      @moves, @positions = [], [rules.new(seed, options)]

      @seed    = @positions.last.seed
      @options = @positions.last.options.dup.freeze

      @created_at = @last_move_at = Time.now
    end

    # Initialize as a deep copy of the given history.

    def initialize_copy(o)
      @rules, @seed, @options = o.rules, o.seed, o.options.dup
      @moves = o.moves.dup
    end

    # Fetch a position from history.  This recreates / caches positions as
    # necessary.

    def [](i)
      return nil           if i >= length
      return @positions[i] if @positions[i]

      if i == 0
        return @positions[i] = rules.new(seed, options)
      end

      # Need to recreate a missing position
      j = i
      j -= 1 until @positions[j]

      until j == i
        @positions[j + 1] = moves[j].apply_to(@positions[j])
        j += 1
      end

      @positions[i]
    end

    # Fetch the first position from history.

    def first
      self[0]
    end

    # Fetch the last position from history.

    def last
      self[length - 1] # Use [] -- positions could be missing
    end

    # How many positions are in this history?  This is based on #moves, and
    # does not represent how many positions are actually stored in the
    # history at any given moment.  Rather it is the number of positions
    # that can be pulled out.

    def length
      moves.length + 1
    end

    # The sequence of moves.  This is deprecated.  History#moves should be
    # used instead.

    def sequence
      moves.map(&:to_s)
    end

    # The censored sequence of moves.  Any sealed moves are replaced with the
    # symbol :hidden.  The list will be censored for the given player (that is
    # a sealed move that the player can see will *not* be hidden).
    #
    # This method depends on Position#sealed_moves.
    #
    # The sealed moves are assumed to come at the end of the sequence of moves.
    # For example, if the sequence is [9,8,7,9] and the sealed_moves are [9,8]
    # the result will be [9,:hidden,7,:hidden].  If the sealed_moves list was
    # [9,9] the result would be [:hidden,8,7,:hidden].
    #
    # TODO:  This should be deprecated in favor of a, yet unwritten,
    #        censored_moves method.

    def censored_sequence(player)
      seq = sequence
      sealed = last.sealed_moves(player).map(&:to_s)

      i = seq.length - 1

      until i < 0 || sealed.empty?
        seq[i] = :hidden if sealed.delete(seq[i])
        i -= 1
      end

      seq
    end

    # A list of who made each move.  This is deprecated.  History#moves should
    # be used instead.

    def move_by
      moves.map(&:by)
    end

    # Add a new position to history.  The given move is applied to the last
    # position in history and the new position is appended to the end of the
    # history.  The player is the player making the move.
    #
    # The move should be a String, it will be wrapped in a Move.  However,
    # passing a Move object is also acceptable.  The move is appended to the
    # History#moves list, but the position is not created until it's accessed
    # through History#[] (or History#last).

    def append(move)
      unless no_timestamps || move.at
        move = move.stamp
      end

      moves << move # this is tricky, the move is applied lazily

      @last_move_at = move.at

      self
    end

    # Delete the last move / position from history.  Returns an array of the
    # [deleted_move, deleted_position].

    def undo
      last # make sure the last position is available
      [moves.pop, @positions.pop]
    end

    # Iterate over the positions in this history.

    def each
      moves.length.times { |i| yield moves[i], self[i] }
    end

    # Retrieve positions created since the given time (based on Move#at and
    # History#moves).  Note, because this is based on Move#at, there isn't
    # a timestamp for when the first position was created (TODO).

    def since(time)
      ps, i = [], moves.length - 1
      time += 0.00001
      while i >= 0 && (m = moves[i]) && m.at && m.at > time
        ps.unshift self[i + 1]
        i -= 1
      end
      ps
    end

    # Get the moves made during the last turn.  The special parameter indicates
    # whether or not to include special moves.  The default is to filter them
    # out (which means the array of moves returned may be empty).
    #
    # Also note that last_turn may not represent a complete turn (imagine that
    # a player has already made two moves, and it's still his or her turn.  The
    # first two moves will be returned even though the turn is not complete.

    def last_turn(i=moves.length - 1, special=false)
      ms = []

      while i >= 0 && (m = moves[i])
        break if !special && m.special?

        if ms.empty?
          ms << m
        elsif m.by == ms.last.by
          ms.unshift m
        else
          break
        end

        i -= 1
      end

      ms
    end

    # Compare History objects.  Positions are not compared.  If the rules,
    # seed, options and moves list are equal, the histories are considered
    # equal.

    def eql?(other)
      rules == other.rules &&
      seed == other.seed &&
      options == other.options &&
      moves == other.moves
    end

    # Compare History objects.

    def ==(other)
      eql?(other)
    end

    # For efficiency's sake don't dump the entire positions array

    def _dump(depth=-1)
      ps = @positions

      if length > 6
        ps = [nil] * length
        ps[0] = @positions.first
        r = ((ps.length - 6)..(ps.length - 1))
        ps[r] = @positions[r]
      end

      Marshal.dump [rules, seed, options, moves, last_move_at, created_at, ps]
    end

    # Load mashalled data.

    def self._load(s)
      r, s, o, m, lma, ca, p =
        Marshal.load(s) # rubocop:disable Security/MarshalLoad
      h = allocate
      h.instance_variable_set('@rules', r)
      h.instance_variable_set('@seed', s)
      h.instance_variable_set('@options', o)
      h.instance_variable_set('@moves', m)
      h.instance_variable_set('@last_move_at', lma)
      h.instance_variable_set('@created_at', ca)
      h.instance_variable_set('@positions', p)
      h
    end

  end
end
