# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'random'
require 'yaml'

# RandomNumberGenerator is a thin wrapper around Random::MersenneTwister.  It
# provides a simpler interface to Rules that have random elements.  It also
# has a few small benefits over Random::MersenneTwister.  For one, it provides
# faster, lazier (deep) dup'ing, marshaling, and yaml-izing.  It also provides
# a quick equality check.

class RandomNumberGenerator
  attr_reader :seed, :count

  # Provide the seed to initialize the RandomNumberGenerator with.  If no
  # seed is given one will be taken from Kernel.rand (given a max of 2**30-1).

  def initialize( seed=nil )
    @seed = seed || Kernel.rand( 2**30-1 )
    @count = 0
    @rng = Random::MersenneTwister.new( seed )
  end

  # Same as Kernel.rand, but uses MersenneTwister.

  def rand( n=nil )
    if @rng.nil?
      @rng = Random::MersenneTwister.new( seed )
      count.times { @rng.rand }
    end

    @count += 1
    @rng.rand( n )
  end

  # Makes a deep, lazy copy of this RandomNumberGenerator.  The MersenneTwiser
  # that's used behind the scenes is *not* recreated until the first call
  # to #rand.

  def dup
    rng = self.class.allocate
    rng.instance_variable_set( "@seed", seed )
    rng.instance_variable_set( "@count", count )
    rng
  end

  # Compare this rng against another.

  def eql?( o )
    seed == o.seed && count == o.count
  end

  # Compare this rng against another.

  def ==( o )
    eql? o
  end

  # Only the seed and count are dumped when marshalling.

  def _dump( depth=-1 )
    Marshal.dump( [seed, count] )
  end

  # Load mashalled data.

  def self._load( s )
    s, c = Marshal.load( s )
    rng = self.allocate
    rng.instance_variable_set( "@seed", s )
    rng.instance_variable_set( "@count", c )
    rng
  end

  # Only the seed and count are written out to YAML.

  def to_yaml_properties
    ["@seed","@count"]
  end

end

class Array

  # Get a deep copy of this Array (and deep copies of all its elements).

  def deep_dup
    nd = [Symbol, NilClass, Fixnum, TrueClass, FalseClass]
    d = self.dup

    each_index do |i|
      if !nd.include?( self[i].class )
        d[i] = self[i].respond_to?( :deep_dup ) ? self[i].deep_dup : self[i].dup
      end
    end

    d
  end
end

class Hash

  # Get a deep copy of this Hash (and deep copies of all its elements).

  def deep_dup
    nd = [Symbol, NilClass, Fixnum, TrueClass, FalseClass]
    d = self.dup

    each do |k,v|
      if !nd.include?( v.class )
        d[k] = v.respond_to?( :deep_dup ) ? v.deep_dup : v.dup
      end
    end

    d
  end
end

# This is the core of the Vying library.  Rules subclasses provide methods
# that define the initial position of a game, valid moves that may be applied
# to positions, successor positions (as moves are applied), and the definition
# of final positions.
#
# The positions we refer to are actually Rules instances.
#
# To implement a game, a Rules subclass should be created that implements
# these methods:
#
#   #initialize - creates the initial position
#   #move?      - tests the validity of a move against a position
#   #moves      - provides a list of all possible moves for a position
#   #apply!     - apply a move to a position, changing it into its successor
#                 position
#   #final?     - tests whether or not the position is terminal (no more 
#                 moves/successors)
#   #winner?    - defines the winner of a final position
#   #loser?     - defines the loser of a final position
#   #draw?      - defines whether or not the final position represents a draw
#

class Rules

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

  # A Rules instance represents a position in a game, so #initialize should
  # provide the starting position.  If the position contains random elements
  # it should accept a seed to provide repeatability.  If no seed is provided
  # one should be randomly created.
  #
  # If Rules.random has been called, #initialize will automatically create
  # @seed and @rng instance variables and attributes.
  #
  # @turn is also set automatically to a copy of the players array.

  def initialize( seed=nil )
    if info[:random] ||= false
      @seed = seed.nil? ? rand( 10000 ) : seed
      @rng = RandomNumberGenerator.new( @seed )
    end
    @turn = players.dup
  end

  # Attempts to provide an equality check by comparing unignored instance
  # variables.  If an instance variable has no weight in the equality of
  # two positions, use Rules.ignore to omit it from this check.

  def eql?( o )
    return false if instance_variables.sort != o.instance_variables.sort
    instance_variables.each do |iv|
      if instance_variable_get(iv) != o.instance_variable_get(iv) && 
         !self.ignored?( iv )
        return false
      end
    end
    true
  end

  # See Rules#eql?

  def ==( o )
    eql?( o )
  end

  # Does the game defined by these rules allow the players to call a draw
  # by agreement?  If not, draws can only be achieved (if at all) through game
  # play.  This method is used like so:
  #
  #   class BlahRules < Rules
  #     allow_draws_by_agreement
  #   end
  #
  # This value can later be retrieved by subsequent calls to
  # #allow_draws_by_agreement or info[:allows_draws_by_agreement].

  def self.allow_draws_by_agreement
    info[:allow_draws_by_agreement] = true
  end

  # Returns whether this game allows the players to negotiate draws.

  def allow_draws_by_agreement?
    info[:allow_draws_by_agreement]
  end

  # Indicates that an instance variable should be ignored (for purposes of
  # equality).  This can be used like so:
  #
  #   class BlahRules < Rules
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

  # Used to indicate that a game has random elements.  This will setup seed
  # and rng attributes.  The rng will be populated with a random number
  # generator that can be used to setup these random elements.
  #
  #   class BlahRules < Rules
  #     random
  #   end
  #
  # If called, random will also set info[:random] to true.

  def self.random
    info[:random] = true
    attr_reader :seed, :rng
  end

  # This rand provides the same interface as Kernel.rand but is backed by
  # the rng created by Rules.random.

  def rand( n=nil )
    @rng ? @rng.rand( n ) : Kernel.rand( n )
  end

  # Define sensitive position data that should be hidden from players.  This
  # takes a hash mapping player to an array of the instance variables that
  # should be hidden from the player.

  def self.censor( h={}, p=nil )
    @censored = h
    class << self
      undef_method :censor
      attr_reader :censored
    end
  end

  # Hide sensitive position data from the given player.  This creates a
  # censored copy of this position.  Sensitive instance variables will be
  # overwritten with :hidden. 
  #
  # If Rules.random has been called to create seed and rng instance variables,
  # #censor will overwrite them with :hidden.
  #
  # Use this method with Rules.censor, or override it (more common) to 
  # customize what data is censored.

  def censor( player )
    pos = self.dup

    pos.instance_eval( "@rng, @seed = :hidden, :hidden" ) if pos.info[:random]

    return pos unless pos.respond_to? :censored
    return pos if     censored[player].nil?

    censored[player].each do |f|
      pos.instance_eval( "@#{f} = :hidden" )
    end

    pos
  end

  # Disallow cycles.

  def self.no_cycles
    @no_cycles = true
  end

  # Are we checking for cycles?

  def self.check_cycles?
    @no_cycles
  end

  def self.name( *args )
    method_missing( :name, *args )
  end

  class << self
    attr_reader :info

    # method_missing is used to setup dsl like access to the info array.
    # This enables, the following, for example:
    #     class Blah < Rules
    #       name "Blah Blah Game"
    #       version "0.0.1"
    #     end
    #
    #     Blah.name => "Blah Blah Game"
    #     Blah.version => "0.0.1"
    #
    # Combined with Rules#method_missing, the following is possible:
    #
    #     Blah.new.name => "Blah Blah Game"
    #     Blah.new.version => "0.0.1"
    #
    # Combined with Game#method_missing, the following is possible:
    #
    #     g = Game.new Blah
    #     g.name => "Blah Blah Game"
    #     g.version => "0.0.1"
    #

    def method_missing( m, *args )
      @info ||= {}
      if info.key?( m ) && args.length == 0
        info[m]
      elsif ! info.key?( m ) && args.length == 1
        info[m] = args.first.freeze
      else
        super
      end
    end

    # See Rules.version.

    def respond_to?( m )
      super || info.key?( m )
    end
  end

  # Missing methods are tried as class methods.  So, Rules.players can be
  # called as Rules#players.

  def method_missing( m, *args )
    self.class.respond_to?( m ) ? self.class.send( m, *args ) : super
  end

  # See #method_missing.

  def respond_to?( m )
    super || self.class.respond_to?( m )
  end

  # Who's turn is it?  Who's turn will it be next?  
  #
  #   rules.turn  <-- who's turn is it?
  #   rules.turn( :next )  <-- who's turn will be next?
  #   rules.turn( :rotate )  <-- should only be used by subclasses, changes the
  #                              turn
  #
  # #turn should not be relied upon outside of implementing subclasses.
  # Instead, use #has_moves.

  def turn( action=:now )
    case action
      when :now    then return @turn[0]
      when :next   then return @turn[1] if @turn.size > 1
      when :rotate
        @turn << @turn.delete_at( 0 )
    end
    @turn[0]
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

  # If the position is final?, does it represent a draw?  This default
  # implementation returns false everytime.  This is great for rules which
  # forbid draws.

  def draw?
    false
  end

  # Do these rules define a score? 

  def has_score?
    respond_to?( :score )
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
  # position, returning the results.  Implementing subclasses should provide
  # an implementation of #apply!, which should do the same thing without making
  # a dup first.

  def apply( move )
    self.dup.apply!( move )
  end

  # Scans the RUBYLIB (unless overridden via path), for rules subclasses and
  # requires them.  Looks for files that match:
  #
  #   <Dir from path>/**/rules/**/*.rb
  #

  def Rules.require_all( path=$: )
    required = []
    path.each do |d|
      Dir.glob( "#{d}/**/rules/**/*.rb" ) do |f|
        f =~ /(.*)\/rules\/.*\/([\w\d]+\.rb)$/
        if ! required.include?( $2 ) && !f["_test"]
          required << $2
          require "#{f}"
        end
      end
    end
  end

  @@rules_list = []

  # When a subclass extends Rules, it is added to @@rules_list.

  def self.inherited( child )
    @@rules_list << child
  end

  # Get a list of all Rules subclasses.

  def Rules.list
    @@rules_list
  end

  # Find a rules subclass.  Takes a string and returns the subclass.  This
  # method will try a couple transformations on the string to find a match
  # in Rules.list.  For example, "keryo_pente" will find KeryoPente.

  def Rules.find( name )
    Rules.list.each do |r|
      return r if name == r ||
                  name.to_s.downcase == r.to_s.downcase ||
                  name.to_s.downcase == r.to_snake_case
    end
    nil
  end

  # Returns a very basic string representation of this position.

  def to_s
    s = ''
    fs = instance_variables.map { |iv| iv.to_s.length }.max + 2
    instance_variables.sort.each do |iv|
      next if ignored? iv

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

  # Turns a Rules class name into snake case:  KeryoPente to "keryo_pente".

  def Rules.to_snake_case
    s = to_s
    s.gsub!( /(.)([A-Z])/ ) { "#{$1}_#{$2.downcase}" }
    s.downcase
  end

  # Shorter alias for Rules.to_snake_case

  def Rules.to_sc
    to_snake_case
  end

  # This is needed because we regularly override Class#name which is used
  # by YAML to set the type.

  def to_yaml_type
    "!ruby/object:#{self.class}"
  end

  class << self
    private :allow_draws_by_agreement
  end

  def forfeit?;                    false;                   end
  def forfeit_by;                  nil;                     end
  def forfeit_by?( player )        false;                   end
  def time_exceeded?;              false                    end
  def time_exceeded_by;            nil;                     end
  def time_exceeded_by?( player ); false;                   end
  def draw_by_agreement?;          false;                   end
  def draw_offered?;               false;                   end
  def draw_offered_by;             nil;                     end
  def draw_offered_by?( player );  false;                   end
end

module Forfeit
  def special_move=( special_move )
    if special_move =~ /^forfeit_by_(\w+)/
      @forfeit_by = $1.intern
    end
  end

  def forfeit?;                    true;                    end
  def forfeit_by;                  @forfeit_by;             end
  def forfeit_by?( player );       @forfeit_by == player;   end
  def final?;                      true;                    end
  def winner?( player );           player != @forfeit_by;   end
  def loser?( player );            player == @forfeit_by;   end
  def moves( player=nil );         [];                      end
  def move?( move, player=nil );   false;                   end
  def has_moves;                   [];                      end
end

module TimeExceeded
  def special_move=( special_move )
    if special_move =~ /^time_exceeded_by_(\w+)/
      @exceeded_by = $1.intern
    end
  end

  def time_exceeded?;              true;                    end
  def time_exceeded_by;            @exceeded_by;            end
  def time_exceeded_by?( player ); @exceeded_by == player;  end
  def final?;                      true;                    end
  def winner?( player );           player != @exceeded_by;  end
  def loser?( player );            player == @exceeded_by;  end
  def moves( player=nil );         [];                      end
  def move?( move, player=nil );   false;                   end
  def has_moves;                   [];                      end
end

module NegotiatedDraw
  def special_move=( special_move )
  end

  def draw_by_agreement?;          true;                    end
  def final?;                      true;                    end
  def winner?( player );           false;                   end
  def loser?( player );            false;                   end
  def draw?;                       true;                    end
  def moves( player=nil );         [];                      end
  def move?( move, player=nil );   false;                   end
  def has_moves;                   [];                      end
end

module DrawOffered
  def special_move=( special_move )
    if special_move =~ /^draw_offered_by_(\w+)/
      @offered_by = $1.intern
    end
  end

  def draw_offered?;               true;                    end
  def draw_offered_by;             @offered_by;             end
  def draw_offered_by?( player );  @offered_by == player;   end
  def final?;                      false;                   end
  def moves( player=nil );         [];                      end
  def move?( move, player=nil );   false;                   end
  def has_moves;                   players - [@offered_by]; end
end

