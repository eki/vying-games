# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

#  History component of a Game.  This is the sequence and position cache.
#  It behaves much like an array but doesn't write out every position when
#  being serialized (and thus needs to be able to recreate positions based
#  on the move history as necessary.

class History
  include Enumerable

  attr_reader :rules, :seed, :options, :moves

  attr_accessor :no_timestamps

  # Takes the ingredients for the first position (rules, seed, options) and
  # initializes a history.

  def initialize( rules, seed, options )
    @rules, @seed, @options = rules, seed, options
    @moves, @positions = [], [rules.new( seed, options )]
    @seed ||= @positions.last.seed
  end

  # Initialize as a deep copy of the given history.

  def initialize_copy( o )
    @rules, @seed, @options = o.rules, o.seed, o.options.dup
    @moves = o.moves.dup
  end

  # Fetch a position from history.  This recreates / caches positions as
  # necessary.

  def []( i )
    @positions ||= []  # may have been erased during YAML serialization

    return nil           if i >= length
    return @positions[i] if @positions[i]

    if i == 0
      return @positions[i] = rules.new( seed, options )
    end

    # Need to recreate a missing position
    j = i
    until @positions[j]
      j -= 1
    end

    until j == i
      @positions[j+1] = moves[j].apply_to( @positions[j] )
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
    self[length-1] # Use [] -- positions could be missing
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
    moves.map { |m| m.to_s }
  end

  # A list of who made each move.  This is deprecated.  History#moves should
  # be used instead.

  def move_by
    moves.map { |m| m.by }
  end

  # Add a new position to history.  The given move is applied to the last
  # position in history and the new position is appended to the end of the
  # history.  The player is the player making the move.
  #
  # The move should be a String, it will be wrapped in a Move.  However,
  # passing a Move object is also acceptable.  The move is appended to the
  # History#moves list, but the position is not created until it's accessed
  # through History#[] (or History#last).

  def append( move, player )
    if no_timestamps
      m = Move.new( move, player, nil )
    else
      m = Move.new( move, player )
    end

    moves << m    # this is tricky, the move is applied lazily
    self
  end

  # Delete the last move / position from history.  Returns an array of the
  # [deleted_move, deleted_position].

  def undo
    last  # make sure the last position is available
    [moves.pop, @positions.pop]
  end

  # Iterate over the positions in this history.

  def each
    moves.length.times { |i| yield moves[i], self[i] }
  end

  # Compare History objects.  Positions are not compared.  If the rules,
  # seed, options and moves list are equal, the histories are considered
  # equal.

  def eql?( o )
    rules == o.rules &&
    seed == o.seed &&
    options == o.options &&
    moves == o.moves
  end

  # Compare History objects.

  def ==( o )
    eql? o
  end

  # For efficiency's sake don't dump the entire positions array

  def _dump( depth=-1 )
    ps = @positions

    if length > 6
      ps = [nil] * length
      ps[0] = @positions.first
      r = ( (ps.length - 6)..(ps.length - 1) )
      ps[r] = @positions[r]
    end

    Marshal.dump( [rules, seed, options, moves, ps] )
  end

  # Load mashalled data.

  def self._load( s )
    r, s, o, m, p = Marshal.load( s )
    h = self.allocate
    h.instance_variable_set( "@rules", r )
    h.instance_variable_set( "@seed", s )
    h.instance_variable_set( "@options", o )
    h.instance_variable_set( "@moves", m )
    h.instance_variable_set( "@positions", p )
    h
  end

  # Only the rules, seed, options, and moves are written to yaml.  The 
  # positions are left out because they can be recreated.  Note: this behavior
  # is different from Marshal dump which simply omits parts of the positions
  # array.

  def to_yaml_properties
    ["@rules","@seed", "@options", "@moves"]
  end

end

