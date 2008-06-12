# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

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

  # Define an actual hash function

  def hash
    [keys, values].hash
  end
end

# Represents the default and valid values for an option used with Rules#option,
# Rules#initialize, and Rules#validate.

class Option
  attr_reader :name, :default, :values

  def initialize( name, opts={} )
    @name, @default, @values = name, opts[:default], opts[:values]

    raise "default required for option" unless @default
    raise "values required for option" unless @values
    raise "values must include the default" unless @values.include?( @default )
  end

  def coerce( value )
    if default.kind_of?( Symbol )
      value = value.to_sym
    elsif default.kind_of?( Integer ) && ! value.kind_of?( Symbol )
      value = value.to_i
    elsif default.kind_of?( Float )
      value = value.to_f
    elsif default.kind_of?( String )
      value = value.to_s
    end

    value
  end

  def validate( value )
    value = coerce( value )

    unless values.include?( value )
      raise "#{value.inspect} is not valid for #{name}, try #{values.inspect}"
    end

    true
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

  attr_reader :options

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

  # Attempt to find the exact version as requested, and instantiate it.
  # If the version cannot be found, fall back to creating an instance of
  # self.
  #
  # Example, given classes Kalah and Kalah_1_0_0:
  #
  #   Kalah.new( :version => "2.0.0" )  => #<Kalah ...>
  #   Kalah.new( :version => "1.0.0" )  => #<Kalah_1_0_0 ...>
  #
  # The special option :version is deleted from the options hash in either
  # case.

  def self.new( seed=nil, options={} )
    if seed.class == Hash
      seed, options = nil, seed
    end

    if v = options.delete( :version )
      ks = "#{to_s}_#{v.gsub( /\./, '_' )}"
      if Object.const_defined?( ks )
        klass = Object.const_get( ks )
        return klass.new( seed, options )
      end
    end

    super( seed, options )
  end

  # A Rules instance represents a position in a game, so #initialize should
  # provide the starting position.  If the position contains random elements
  # it should accept a seed to provide repeatability.  If no seed is provided
  # one should be randomly created.
  #
  # If Rules.random has been called, #initialize will automatically create
  # @seed and @rng instance variables and attributes.
  #
  # The given options are validated against info[:options].  Defaults are
  # merged in and the @options instance variable initialized.
  #
  # If the :number_of_players option is specified, @players is adjusted to
  # contain the first N players from info[:players].
  #
  # @turn is also set automatically to a copy of the @players array.

  def initialize( seed=nil, options={} )
    if seed.class == Hash
      seed, options = nil, seed
    end

    if info[:random] ||= false
      @seed = seed.nil? ? rand( 10000 ) : seed
      @rng = RandomNumberGenerator.new( @seed )
    end

    defaults = {}
    (info[:options] || {}).each { |name,opt| defaults[name] = opt.default }

    options = defaults.merge!( options )
    if validate( options )
      @options = options
      coerce_options
    end

    n = options[:number_of_players] || players.length
    n = n.to_i

    @players = players[0...n].dup.freeze
    @turn = @players.dup
  end

  # Attempt to coerce the given opts into the default type.

  def coerce_options
    options.each do |name, value|
      options[name] = info[:options][name].coerce( value )
    end
  end

  # Validate options that can be passed to Rules#initialize.  The default
  # implementation checks that the keys in options match up to the hash keys
  # info[:options].  Subclasses should override and validate the values of the
  #  options.

  def validate( opts )
    diff = opts.keys - (info[:options] || {}).keys

    if diff.length == 1
      raise "#{diff.first} is not a valid option for #{name}"
    elsif ! diff.empty?
      raise "#{diff.inspect} are not valid options for #{name}"
    end

    opts.all? do |name,value|
      info[:options][name].validate( value )
    end
  end

  # A little kludgy, but provides validate as a class method.

  def self.validate( opts )
    new.validate( opts )
  end

  # Create's an option for the Rules subclass.  These are stored in 
  # info[:options], and are used for setting defaults and valid values for
  # the options passed to Rules#initialize.
  #
  # For example:
  #
  #   class BlahRules < Rules
  #     option :board_size, :default => 12, :values => [10, 11, 12, 13]
  #   end
  #

  def self.option( name, options )
    info[:options] ||= {}
    info[:options][name] = Option.new( name, options )
  end

  # Returns the players for a position.  This may be the instance variable
  # @players, if defined, or the value in info[:players].  Note, info[:players]
  # should be used to enumerate the maximum number of players.  If the rules
  # allow for variable players, @players should contain the first N players
  # from info[:players].  Rules#initialize handles this automatically via
  # the option :number_of_players.

  def players
    @players || self.class.players
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
  # This value can later be retrieved by calling
  # #allow_draws_by_agreement? or info[:allows_draws_by_agreement].

  def self.allow_draws_by_agreement
    info[:allow_draws_by_agreement] = true
  end

  # Returns whether this game allows the players to negotiate draws.

  def allow_draws_by_agreement?
    info[:allow_draws_by_agreement]
  end

  # Is this game's outcome determined by score?  Setting this causes the
  # default implementations of #winner?, #loser?, and #draw? to use score.
  # The Rules subclass therefore only has to define #score.  The default
  # implementations are smart enough to deal with more than 2 players.  For
  # example, if there are four players and their scores are [9,9,7,1], the
  # players who scored 9 are winners, the players who scored 7 and 1 are
  # the losers.  If all players score the same, the game is a draw.
  #
  #   class BlahRules < Rules
  #     score_determines_outcome
  #   end
  #
  # This value can later be retrieved by calling
  # #score_determines_outcome? or info[:score_determines_outcome].

  def self.score_determines_outcome
    info[:score_determines_outcome] = true
  end

  # Returns whether this game's outcome is determined by score.

  def score_determines_outcome?
    info[:score_determines_outcome]
  end

  # Does the game defined by these rules allow use of the pie rule?  The
  # pie rule allows the second player to swap sides after the first move
  # is played.
  #
  #   class BlahRules < Rules
  #     pie_rule
  #   end
  #
  # This value can later be retrieved by calling
  # #pie_rule? or info[:pie_rule].

  def self.pie_rule
    info[:pie_rule] = true
  end

  # Returns whether or not this game uses the pie rule.

  def pie_rule?
    info[:pie_rule]
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
      @info[:options] ||= {}
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

  # If the position is final?, is the given player a winner?  Note, that
  # more than one player may be considered winners.  If the rules define a
  # score, it's used.  If the player has the highest score, true
  # is returned.  If the rules do not define a score, false is returned
  # and the Rules subclass should override this method.

  def winner?( player )
    if score_determines_outcome?
      scores = players.map { |p| score( p ) }
      return scores.uniq.length > 1 && score( player ) == scores.max
    end

    false
  end

  # If the position is final?, is the given player a loser?  Note, that
  # more than one player may be considered losers.  If the rules define a
  # score, it's used.  If the player does not have the highest score, true
  # is returned.  If the rules do not define a score, false is returned
  # and the Rules subclass should override this method.

  def loser?( player )
    if score_determines_outcome?
      return score( player ) != players.map { |p| score( p ) }.max
    end

    false
  end

  # If the position is final?, does it represent a draw?  The default
  # implemention returns true if the rules define a score and all players
  # have the same score.  If the rules do not define a score, then false
  # is returned everytime.  Great for games that forbid draws.

  def draw?
    if score_determines_outcome?
      return players.map { |p| score( p ) }.uniq.length == 1
    end

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

  def apply( move, player=nil )
    self.dup.apply!( move, player=nil )
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
        f =~ /(.*)\/rules\/(.*\/[\w\d]+\.rb)$/
        if ! required.include?( $2 ) && !f["_test"]
          required << $2
          require "#{f}"
        end
      end
    end

    @@rules_list.reject! do |r|
      r.to_s =~ /\w+_\d+_\d+_\d+/ &&  # Evict old versions of rules
      r.name !~ /\w+_\d+_\d+_\d+/
    end
  end

  @@rules_list = []

  # When a subclass extends Rules, it is added to @@rules_list.

  def self.inherited( child )
    @@rules_list << child
  end

  # Get a list of all Rules subclasses.

  def Rules.list
    if Vying::RandomSupport
      @@rules_list
    else
      @@rules_list.reject { |r| r.info[:random] }
    end
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

