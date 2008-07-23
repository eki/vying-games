# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

#  History component of a Game.  This is the sequence and position cache.
#  It behaves much like an array but doesn't write out every position when
#  being serialized (and thus needs to be able to recreate positions based
#  on the sequence when necessary.

class History
  include Enumerable

  attr_reader :sequence, :positions, :move_by

  SPECIAL_MOVES = { /^draw_offered_by_/     => DrawOffered,
                    /^draw_accepted_by_/    => DrawAccepted,
                    /^undo_requested_by_/   => UndoRequested,
                    /^undo_accepted_by_/    => UndoAccepted,
                    /_resigns$/             => Resign,
                    /^time_exceeded_by_/    => TimeExceeded,
                    /^draw$/                => NegotiatedDraw,
                    /^swap$/                => Swapped }

  # Takes the initial position and initializes the sequence and positions
  # arrays.

  def initialize( start )
    @sequence, @move_by, @positions = [], [], [start]
  end

  # Fetch a position from history.

  def []( i )
    return nil          if i >= length
    return positions[i] if positions[i]

    # Need to recreate a missing position
    j = i
    until positions[j]
      j -= 1
    end

    until j == i
      p = nil

      SPECIAL_MOVES.each do |pattern, mod|
        if sequence[j] =~ pattern
          p = positions[j].dup
          p.extend mod
          p.special_moves = last_special_moves( j )
        end
      end

      p ||= positions[j].apply( sequence[j] )

      positions[j+1] = p
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
    self[length-1] # Use [] -- positions could be missing
  end

  # Is the last move special?

  def special?( move )
    SPECIAL_MOVES.keys.any? { |p| move =~ p }
  end

  # Get all the special moves from the end of the sequence.  If a parameter
  # is given it will be used as the index to start searching from (instead
  # of the end of the sequence.

  def last_special_moves( i=nil )
    i ||= sequence.length - 1
    sms = []

    while i > 0 && special?( sequence[i] )
      sms << sequence[i]
      i -= 1
    end

    sms
  end

  # How many positions are in this history?

  def length
    sequence.length + 1
  end

  # Add a new position to history.  The given move is applied to the last
  # position in history and the new position is appended to the end of the
  # history.  The player is the player making the move.

  def append( move, player )
    p = nil

    SPECIAL_MOVES.each do |pattern, mod|
      if move =~ pattern
        p = last.dup
        p.extend mod
        p.special_moves = [move] + last_special_moves
      end
    end

    p ||= last.apply( move, player )

    positions << p
    sequence << move
    move_by << player
    self
  end

  # Iterate over the positions in this history.

  def each
    sequence.length.times { |i| yield sequence[i], move_by[i], self[i] }
  end

  # Compare History objects.

  def eql?( o )
    positions.first == o.positions.first && 
    sequence == o.sequence &&
    move_by == o.move_by
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

    Marshal.dump( [sequence, move_by, ps] )
  end

  # Load mashalled data.

  def self._load( s )
    s, m, p = Marshal.load( s )
    h = self.allocate
    h.instance_variable_set( "@sequence", s )
    h.instance_variable_set( "@move_by", m )
    h.instance_variable_set( "@positions", p )
    h
  end

end

