
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
    nd = [Symbol, NilClass, Fixnum, TrueClass, FalseClass]
    instance_variables.each do |iv|
      v = instance_variable_get( iv )
      if !nd.include?( v.class )
        instance_variable_set( iv,
          v.respond_to?( :deep_dup ) ? v.deep_dup : v.dup )
      end
    end
  end

  # Attempts to provide an equality check by comparing unignored instance
  # variables.  If an instance variable has no weight in the equality of
  # two positions, use Rules#ignore to omit it from this check.

  def eql?( o )
    return false if instance_variables.sort != o.instance_variables.sort
    instance_variables.each do |iv|
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
    @ignore && @ignore.include?( iv.to_s )
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

  # Is the given move valid for the given player?  If the given player is
  # nil, is the move? valid for any player?  This default implementation is
  # based on #moves.  The move is first forced into a string and then looked
  # for in the #moves list.  This implementation should always be correct
  # (provided #moves is correct), but may be slow and inefficient depending
  # on how time consuming it is for #moves to generate the full list of
  # all possible moves.

  def move?( move, player=nil )
    moves( player ).include?( move.to_s )
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
    self.dup.apply!( move, player=nil )
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

  def forfeit?;                      false;                           end
  def forfeit_by;                    nil;                             end
  def forfeit_by?( player )          false;                           end
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

end

module Forfeit
  def special_moves=( special_moves )
    if special_moves.last =~ /^forfeit_by_(\w+)/
      @forfeit_by = $1.intern
    end
  end

  def forfeit?;                      true;                            end
  def forfeit_by;                    @forfeit_by;                     end
  def forfeit_by?( player );         @forfeit_by == player;           end
  def final?;                        true;                            end
  def winner?( player );             player != @forfeit_by;           end
  def loser?( player );              player == @forfeit_by;           end
  def draw?;                         false;                           end
  def moves( player=nil );           [];                              end
  def move?( move, player=nil );     false;                           end
  def has_moves;                     [];                              end
end

module TimeExceeded
  def special_moves=( special_moves )
    if special_moves.last =~ /^time_exceeded_by_(\w+)/
      @exceeded_by = $1.intern
    end
  end

  def time_exceeded?;                true;                            end
  def time_exceeded_by;              @exceeded_by;                    end
  def time_exceeded_by?( player );   @exceeded_by == player;          end
  def final?;                        true;                            end
  def winner?( player );             player != @exceeded_by;          end
  def loser?( player );              player == @exceeded_by;          end
  def draw?;                         false;                           end
  def moves( player=nil );           [];                              end
  def move?( move, player=nil );     false;                           end
  def has_moves;                     [];                              end
end

module NegotiatedDraw
  def special_moves=( special_moves )
  end

  def draw_by_agreement?;            true;                            end
  def final?;                        true;                            end
  def winner?( player );             false;                           end
  def loser?( player );              false;                           end
  def draw?;                         true;                            end
  def moves( player=nil );           [];                              end
  def move?( move, player=nil );     false;                           end
  def has_moves;                     [];                              end
end

module DrawOffered
  def special_moves=( special_moves )
    if special_moves.last =~ /^draw_offered_by_(\w+)/
      @offered_by = $1.intern
    end
  end

  def draw_offered?;                 true;                            end
  def draw_offered_by;               @offered_by;                     end
  def draw_offered_by?( player );    @offered_by == player;           end
  def final?;                        false;                           end
  def moves( player=nil );           [];                              end
  def move?( move, player=nil );     false;                           end
  def has_moves;                     players - [@offered_by];         end
end

module DrawAccepted
  def special_moves=( special_moves )
    @accepted_by = []

    special_moves.each do |special_move|
      if special_move =~ /^draw_offered_by_(\w+)/
        @offered_by = $1.intern
      elsif special_move =~ /^draw_accepted_by_(\w+)/
        @accepted_by << $1.intern
      end
    end

    @waiting_for = players - [@offered_by] - @accepted_by
  end

  def draw_offered?;                 true;                            end
  def draw_offered_by;               @offered_by;                     end
  def draw_offered_by?( player );    @offered_by == player;           end
  def draw_accepted_by?( player );   @accepted_by.include?( player ); end
  def final?;                        false;                           end
  def moves( player=nil );           [];                              end
  def move?( move, player=nil );     false;                           end
  def has_moves;                     @waiting_for;                    end
end

module UndoRequested
  def special_moves=( special_moves )
    if special_moves.last =~ /^undo_requested_by_(\w+)/
      @requested_by = $1.intern
    end
  end

  def undo_requested?;               true;                            end
  def undo_requested_by;             @requested_by;                   end
  def undo_requested_by?( player );  @requested_by == player;         end
  def final?;                        false;                           end
  def moves( player=nil );           [];                              end
  def move?( move, player=nil );     false;                           end
  def has_moves;                     players - [@requested_by];       end
end

module UndoAccepted
  def special_moves=( special_moves )
    @accepted_by = []

    special_moves.each do |special_move|
      if special_move =~ /^undo_requested_by_(\w+)/
        @requested_by = $1.intern
      elsif special_move =~ /^undo_accepted_by_(\w+)/
        @accepted_by << $1.intern
      end
    end

    @waiting_for = players - [@requested_by] - @accepted_by
  end

  def undo_requested?;               true;                            end
  def undo_requested_by;             @requested_by;                   end
  def undo_requested_by?( player );  @requested_by == player;         end
  def undo_accepted_by?( player );   @accepted_by.include?( player ); end
  def final?;                        false;                           end
  def moves( player=nil );           [];                              end
  def move?( move, player=nil );     false;                           end
  def has_moves;                     @waiting_for;                    end
end

module Swapped
  def special_moves=( special_moves )
  end
end

