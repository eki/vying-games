
class Position

  class << self
    attr_reader :rules
  end

  def rules
    self.class.rules
  end

  attr_reader :players, :seed, :rng, :options

  # Creates the starting position in a game.  

  # The seed parameter provides repeatability of positions that involve
  # random elements.  If Rules#random? is true, @seed and @rng will be
  # initialized automatically by Position#initialize.
  #
  # The options hash should already be validated as being correct.  Further,
  # defaults should already be merged in (ie, no options should be missing).
  #
  # Rules provides the definition of the options, and Rules#start will 
  # handle validation.
  #
  # If the :number_of_players option is specified, @players is adjusted to
  # contain the first N players from Rules#players.
  #
  # @turn is also set automatically to a copy of the @players array.

  def initialize( seed=nil, opts={} )
    if seed.class == Hash
      seed, options = nil, seed
    end

    if rules.random? 
      @seed = seed.nil? ? Kernel.rand( 10000 ) : seed
      @rng = RandomNumberGenerator.new( @seed )
    end

    @options = opts

    n = @options[:number_of_players] || rules.players.length

    @players = rules.players[0...n].dup.freeze
    @turn = @players.dup

    init
  end

  # Subclasses can implement Position#init rather than #intialize.  This
  # will be called after the Position has already been initialized.  By default
  # this does nothing.

  def init

  end

  # All positions should provide a deep copy via #dup.  This initialize_copy
  # attempts to provide such a deep copy by scanning a position's instance
  # variables and copying them.

  def initialize_copy( original )
    instance_variables.each do |iv|
      if iv.to_s =~ /^@__.*_cache$/
        instance_variable_set( iv, nil )
      else
        v = instance_variable_get( iv )
        instance_variable_set( iv, v.deep_dup )
      end
    end
  end

  # __dup will make a deep copy, but will *not* extend the copy with any mixins

  alias_method :__dup, :dup

  # Replaces the original #dup with one that will extend the copy with any
  # special mixins.  (See #extend_special_mixin)

  def dup
    p = __dup
    v = p.instance_variable_get( "@includes" )
    p.extend Kernel.nested_const_get( v ) unless v.nil?
    p
  end

  # Attempts to provide an equality check by comparing unignored instance
  # variables.  If an instance variable has no weight in the equality of
  # two positions, use Rules#ignore to omit it from this check.

  def eql?( o )
    ivs = instance_variables | o.instance_variables
    ivs.each do |iv|
      if instance_variable_get(iv) != o.instance_variable_get(iv) &&
         ! self.class.ignored?( iv )
        return false
      end
    end
    true
  end

  # See Rules#eql?

  def ==( o )
    eql?( o )
  end

  # Indicates that an instance variable should be ignored (for purposes of
  # equality).  This can be used like so:
  #
  #   position do
  #     attr_reader :board, :moves_cache
  #     ignore :moves_cache
  #   end
  #

  def self.ignore( *ivs )
    @ignore ||= ["@ignore"]
    @ignore += ivs.map { |iv| "@#{iv}" }
  end

  # Tests whether or not an instance variable has been ignored.

  def self.ignored?( iv )
    !! ((@ignore && @ignore.include?( iv.to_s )) || iv.to_s =~ /^@__/)
  end

  # Clear any caching done by Rules.cache.  This will set any cache
  # instance variables (of the form /^@__.*_cache$/ to nil.

  def clear_cache
    instance_variables.each do |iv|
      instance_variable_set( iv, nil ) if iv.to_s =~ /^@__.*_cache$/
    end
  end

  # This rand provides the same interface as Kernel.rand but is backed by
  # the @rng.  Raises an exception if rules.random? is not true.

  def rand( n=nil )
    rng ? rng.rand( n ) : raise( "rand not backed by rng" )
  end

  # Hide sensitive position data from the given player.  This creates a
  # censored copy of this position.  Sensitive instance variables will be
  # overwritten with :hidden.
  #
  # If rules.random? is true seed and rng instance variables will be censored.

  def censor( player )
    p = self.dup

    if rules.random?
      p.instance_variable_set( "@seed", :hidden )
      p.instance_variable_set( "@rng",  :hidden )
    end

    p
  end

  # If we're checking for cycles, and one is found, what do we do?

  def cycle_found
  end

  # Who's turn is it?
  #
  # #turn should not be relied upon outside of implementing subclasses.
  # Instead, use #has_moves.

  def turn
    @turn.first
  end

  # Who's turn will it be next?

  def next_turn
    @turn[1]
  end

  # Rotate turn to the next player.

  def rotate_turn
    @turn << @turn.shift
    @turn.first
  end

  # Returns the given player's opponent.  In a two-player game (where this
  # makes the most sense), the player name of the opponent is returned.  In
  # a game of more than 2 players, an array of all opponents is returned.

  def opponent( player )
    if players.length == 2
      return players.first == player ? players.last : players.first
    else
      players.dup - [player]
    end
  end

  # Is the given move valid for the given player?  If the given player is
  # nil, is the move? valid for any player?  This default implementation is
  # based on #moves.  The move is first forced into a string and then looked
  # for in the #moves list.  This implementation should always be correct
  # (provided #moves is correct), but may be slow and inefficient depending
  # on how time consuming it is for #moves to generate the full list of
  # all possible moves.

  def move?( move, player=nil )
    player = move.by  if player.nil? && move.respond_to?( :by )

    moves( player ).any? { |m| m.to_s == move.to_s }
  end

  # If the position is final?, is the given player a winner?  Note, that
  # more than one player may be considered winners.
  #
  # If rules.score_determines_outcome? is true and the given player has the
  # highest score, true is return.
  # 
  # Otherwise, false is returned and the Position subclass should override 
  # this method.

  def winner?( player )
    if rules.score_determines_outcome?
      scores = players.map { |p| score( p ) }
      return scores.uniq.length > 1 && score( player ) == scores.max
    end

    false
  end

  # If the position is final?, is the given player a loser?  Note, that
  # more than one player may be considered losers.
  #
  # If rules.score_determines_outcome? is true and the given player does NOT
  # have the highest score, true is return.
  # 
  # Otherwise, false is returned and the Position subclass should override 
  # this method.

  def loser?( player )
    if rules.score_determines_outcome?
      return score( player ) != players.map { |p| score( p ) }.max
    end

    false
  end

  # If the position is final?, does it represent a draw?
  #
  # If rules.score_determines_outcome? is true, this method returns true only
  # if all players have the same score.
  #
  # If the rules do not define a score, then false is returned everytime.  
  # Great for games that forbid draws.

  def draw?
    if rules.score_determines_outcome?
      return players.map { |p| score( p ) }.uniq.length == 1
    end

    false
  end

  # Returns a list of all the players who have moves from this position.  This
  # default implementation returns an empty array if the position is final? or
  # an array containing the results of a call to #turn.  Games with
  # simultaneous moves should override this method.

  def has_moves
    final? ? [] : [turn]
  end

  # Does the given player have moves?  See #has_moves.

  def has_moves?( player )
    has_moves.include?( player )
  end

  # Apply a move to this position.  The move is applied to a dup of this
  # position, returning the resulting position.  Implementing subclasses 
  # should provide an implementation of #apply!, which should do the same 
  # thing without making a dup first.

  def apply( move, player=nil )
    self.dup.apply!( move, player )
  end

  # Return the successors to this position (that is, map the results of
  # #moves to the positions created by those moves).

  def successors( player=nil )
    moves( player ).map { |move| apply( move, player ) }
  end

  # Extend this Position with a special move mixin.  The mixin changes the
  # behavior of this Position.  For example, mixing in
  # Move::Draw::PositionMixin will change the normal behavior of #draw?.
  # This method is used by SpecialMove#apply_to_position and should probably
  # not be used directly.
  #
  # Note: This returns the extended position, this position remains unchanged.

  def extend_special_mixin( mixin )
    p = __dup
    p.instance_variable_set( "@includes", mixin.to_s )
    p.extend mixin
    p
  end

  # Remove the special move mixin.  This returns a copy of this position
  # without the special mixin.  This position is unchanged.

  def remove_special_mixin
    p = __dup
    p.instance_variable_set( "@includes", nil )
    p
  end

  # Marshal this position.  Don't dump any cache instance variables.

  def _dump( depth=-1 )
    ivs = {}

    instance_variables.each do |iv|
      ivs[iv] = instance_variable_get( iv ) if iv !~ /^@__.*_cache$/
    end

    Marshal.dump( ivs )
  end

  # Load a marshalled position.  See Position#_dump.  Also, reconstitutes
  # any methods that have been mixed in via #extend_special_mixin.

  def self._load( s )
    p, ivs = self.allocate, Marshal.load( s )
    ivs.each do |iv, v| 
      p.instance_variable_set( iv, v )
      p.extend Kernel.nested_const_get( v ) if iv.to_s == "@includes"
    end
    p
  end

  # When serializing to YAML, don't serialize instance variables used for
  # caching (/^@__.*_cache$/).

  def to_yaml_properties
    props = instance_variables
    props.reject! { |iv| iv =~ /^@__.*_cache$/ }
    props
  end

  # When loading a YAML-ized Position, be sure to re-extend any special
  # move mixins.

  def yaml_initialize( t, v )
    v.each do |iv,v| 
      instance_variable_set( "@#{iv}", v )
      extend Kernel.nested_const_get( v ) if iv == "includes"
    end
  end

  # Returns a very basic string representation of this position.

  def to_s
    s = ''
    fs = instance_variables.map { |iv| iv.to_s.length }.max + 2
    instance_variables.sort.each do |iv|
      next if self.class.ignored? iv

      v = instance_variable_get( iv )
      iv = iv.to_s.sub( /@/, '' )
      case v
        when Hash  then s += "#{iv}:".ljust(fs) + "#{v.inspect}\n"
        when Array then s += "#{iv}:".ljust(fs) + "#{v.inspect}\n"
        else
          s += "#{iv}:\n#{v}\n"               if v.to_s =~ /\n/
          s += "#{iv}:".ljust(fs) + "#{v}\n"  if v.to_s !~ /\n/
      end
    end
    s
  end

  # Abbreviated inspect string.

  def inspect
    "#<Position rules: #{rules.class_name}>"
  end

  def resigned?;                     false;                           end
  def resigned_by;                   nil;                             end
  def resigned_by?( player )         false;                           end
  def time_exceeded?;                false                            end
  def time_exceeded_by;              nil;                             end
  def time_exceeded_by?( player );   false;                           end
  def draw_by_agreement?;            false;                           end
  def draw_offered?;                 false;                           end
  def draw_offered_by;               nil;                             end
  def draw_offered_by?( player );    false;                           end
  def draw_accepted_by?( player );   false;                           end
  def undo_requested?;               false;                           end
  def undo_requested_by;             nil;                             end
  def undo_requested_by?( player );  false;                           end
  def undo_accepted_by?( player );   false;                           end

  def draw_accepted?
    draw_offered? && has_moves.empty?
  end

  def undo_accepted?
    undo_requested? && has_moves.empty?
  end

  private

  def __move?( move, player=nil )
    hm = has_moves

    player = move.by  if player.nil? && move.respond_to?( :by )

    return false unless player.nil? || hm.include?( player )

    if method( :__original_move? ).arity == 2
      ps = player ? [player] : hm

      ps.any? { |p| __original_move?( move, p ) }
    else
      __original_move?( move )
    end
  end

  def __moves( player=nil )
    hm = has_moves

    return [] unless player.nil? || hm.include?( player )

    if method( :__original_moves ).arity == 1

      ps = player ? [player] : hm

      ps.map do |p|
        __original_moves( p )
      end.flatten

    else
      __original_moves
    end
  end

  def __apply!( move, player=nil )
    if player.nil?
      if move.respond_to?( :by ) && has_moves.include?( move.by )
        player = move.by
      end
    end

    if method( :__original_apply! ).arity == 2
      if player.nil?
        raise "player for #{move} is required"
      end

      clear_cache

      __original_apply!( move, player )
    else
      clear_cache
      __original_apply!( move )
    end

    self
  end

end

