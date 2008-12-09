
# Rules is the core of the Vying library.  To add a game to the library 
# Rules.create should be used like so:
#
#   Rules.create( "TicTacToe" ) do
#
#     name "Tic Tac Toe"     # Properties of the Rules
#     version "1.0.0"
#     
#     position do            # Define the Position (see the Position class)
#       attr_reader :board
#
#       def initialize( seed=nil, opts={} )
#         # ...
#       end
#
#       # ...
#
#     end
#   end
#
# The first section is used to declare properties of the Rules for the game.
# See Rules::Builder to get an idea of what properties are available.  
#
# The second section is the position definition.  This creates a Position 
# subclass.  A Position is composed of data, for example a board, that will
# vary greatly from game to game.  It also provides methods to perform
# state transitions and determine when a game is finished.  These methods
# should be defined (though it's not always necessary to define them all,
# see Position).
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
#   #score      - if the game has a score, what is the score for this position?
#   #hash       - hash the position
#

class Rules
  # private :new   # TODO

  attr_reader :class_name, :name, :version, :players, :options, :defaults

  def initialize( class_name )
    @class_name, @options, @defaults, @cached = class_name, {}, {}, []
  end

  # Create a new Rules instance.  This takes a class name and block.  Example:
  # 
  #   Rules.create( "TicTacToe" ) do
  #     # ...
  #   end
  #
  # This will create an instance of Rules and assign it to the constant
  # TicTacToe.  If there are multiple versions of the same rules, all but
  # one should be marked as broken:
  #
  #   Rules.create( "TicTacToe" ) do
  #     version "1.0.0"
  #   end
  #
  #   Rules.create( "TicTacToe" ) do
  #     version "0.9.0"
  #     broken
  #   end
  #
  # The block is executed in the context of a Rules::Builder.

  def self.create( class_name, &block )
    rules = new( class_name )
    builder = Builder.new( rules )
    builder.instance_eval( &block )

    rules.instance_variables.each do |iv|
      rules.instance_variable_get( iv ).freeze
    end

    unless rules.broken?
      Kernel.const_set( class_name, rules )
    end

    list << rules

    in_list = false
    latest_versions.length.times do |i|
      if latest_versions[i].class_name == rules.class_name
        if rules.version > latest_versions[i].version
          latest_versions[i] = rules
        end
        in_list = true
      end
    end

    latest_versions << rules unless in_list
  end

  # Returns a starting position for these rules.  The given options are
  # validated against #options.

  def new( seed=nil, opts={} )
    if seed.class == Hash
      seed, opts = nil, seed
    end

    opts = defaults.dup.merge!( opts )
    if validate( opts )
      opts.each do |name, value|
        opts[name] = options[name].coerce( value )
      end
    end

    position_class.new( seed, opts )
  end

  # Return a list of all available versions of these rules.

  def versions
    Rules.list.select { |r| r.class_name == class_name }.
               map { |r| r.version }.
               sort
  end

  # Returns the Position subclass used by these rules.

  def position_class
    pkn = "#{class_name}_#{version.gsub( /\./, '_' )}"
    Positions.const_get( pkn )
  end

  # Returns a list of all Position subclasses used by every available version
  # of these rules.

  def position_classes
    versions.map { |v| Rules.find( class_name, v ) }.
             map { |r| r.position_class }
  end

  # Validate options that can be passed to Rules#new.  Checks that all
  # options are present, and then passes the value onto Option#validate.
  # Will raise an exception if anything is invalid.

  def validate( opts )
    diff = opts.keys - options.keys

    if diff.length == 1
      raise "#{diff.first} is not a valid option for #{name}" 
    elsif ! diff.empty?
      raise "#{diff.inspect} are not valid options for #{name}"
    end

    opts.all? do |name,value|
      options[name].validate( value )
    end
  end

  # Are these rules broken?  Rules should only be declared broken if there
  # is a newer version that is not broken.  Broken rules still show up in
  # Rules.list, but do not get to claim the contant named by create.
  #
  # For example:
  #
  #   Rules.create( "Kalah" ) do
  #     version "1.0.0"
  #     broken
  #   end
  #
  #   Rules.create( "Kalah" ) do
  #     version "2.0.0"
  #   end
  #
  # In the above example, the constant Kalah will refer to the second set
  # of rules, though both will appear in Rules.list.

  def broken?
    @broken
  end

  # Is the given player one of the players for these rules?
  #
  # This is the equivalent of:
  #
  #   players.include?( p )
  #

  def player?( p )
    players.include?( p )
  end

  # Does the game defined by these rules have random elements?
  #
  # This property can be set like this:
  #
  #   Rules.create( "Ataxx" ) do
  #     random
  #   end
  #

  def random?
    @random
  end

  # Should caching be applied to the given method?
  #
  # Example:
  #
  #   Rules.create( "AmericanCheckers" ) do
  #     cache :init
  #   end
  #
  #   > AmericanCheckers.cached?( :init )
  #   => true

  def cached?( m )
    @cached.include?( m )
  end

  # Does the game defined by these rules allow the players to call a draw
  # by agreement?  If not, draws can only be achieved (if at all) through game
  # play.  This property can be set like this:
  #
  #   Rules.create( "AmericanCheckers" ) do
  #     allow_draws_by_agreement
  #   end
  #

  def allow_draws_by_agreement?
    @allow_draws_by_agreement
  end

  # Is this game's outcome determined by score?  Setting this causes the
  # default implementations of #winner?, #loser?, and #draw? to use score.
  # The Rules subclass therefore only has to define #score.  The default
  # implementations are smart enough to deal with more than 2 players.  For
  # example, if there are four players and their scores are [9,9,7,1], the
  # players who scored 9 are winners, the players who scored 7 and 1 are
  # the losers.  If all players score the same, the game is a draw.
  #
  #   Rules.create( "Hexxagon" ) do
  #     score_determines_outcome
  #   end
  #

  def score_determines_outcome?
    @score_determines_outcome
  end

  # Do these rules define a score?

  def has_score?
    position_class.instance_method_defined?( 'score' ) 
  end

  # Does the game defined by these rules allow use of the pie rule?  The
  # pie rule allows the second player to swap sides after the first move
  # is played.
  #
  #   Rules.create( "Hex" ) do
  #     pie_rule
  #   end
  #

  def pie_rule?
    @pie_rule
  end
 
  # Do the rules require that we check for cycles?  A cycle is a repeated
  # position during the course of a game.  If this is set, Game will call
  # Position#found_cycle if a cycle occurs.
  #
  #   Rules.create( "Oware" ) do
  #     check_cycles
  #   end
  #

  def check_cycles?
    @check_cycles
  end

  # Do these rules use sealed moves (aka simultaneous moves)?  More than one
  # player can move at a time, the moves are sealed until all (or some subset
  # of more than one player) have moved.  This result is based on the arity
  # of the Position subclass' #moves and #apply! methods (if they take a 
  # player parameter it's assumed the rules allow for sealed moves).

  def sealed_moves?
    return @sealed_moves if @sealed_moves

    if position_class.private_instance_method_defined?( '__original_moves' )
      original_moves = position_class.instance_method( :__original_moves )
    end

    if position_class.private_instance_method_defined?( '__original_apply!' )
      original_apply = position_class.instance_method( :__original_apply! )
    end

    @sealed_moves = (! original_moves || original_moves.arity == 1) &&
                    (! original_apply || original_apply.arity == 2)
  end

  # The prefered notation for this game.

  def notation
    @notation
  end

  # Terse inspect string for a Rules instance.

  def inspect
    "#<Rules name: '#{name}', version: #{version}>"
  end

  # TODO: Clean this up a little more.

  def method_missing( m, *args )
    iv = instance_variable_get( "@#{m}" )
    iv || super
  end

  # TODO: Clean this up a little more.

  def respond_to?( m )
    super || !! (instance_variable_defined?( "@#{m}" ))
  end

  # Returns the name attribute of these Rules.  If name hasn't been set, the
  # class name is returned.

  def to_s
    name || class_name
  end

  # Turns a Rules class name into snake case:  KeryoPente to "keryo_pente".

  def to_snake_case
    s = class_name.dup
    unless s =~ /^[A-Z\d]+$/
      s.gsub!( /(.)([A-Z])/ ) { "#{$1}_#{$2.downcase}" }
    end
    s.downcase
  end

  # Shorter alias for Rules#to_snake_case

  alias_method :to_sc, :to_snake_case

  # Only need to dump the name, version.

  def _dump( depth=-1 )
    Marshal.dump( [class_name, version] )
  end

  # Load mashalled data.

  def self._load( s )
    class_name, version = Marshal.load( s )
    Rules.find( class_name, version )
  end

  yaml_as "tag:ruby.yaml.org,2002:object:Rules"

  # Take over YAML deserialization.  Perform a lookup via Rules.find instead
  # of allocating a new Rules object.

  def Rules.yaml_new( klass, tag, val )
    Rules.find( val['class_name'], val['version'] )
  end

  # Dumps this Rules object to YAML.  Only the class_name and 
  # version are dumped.

  def to_yaml_properties
    ["@class_name", "@version"]
  end

  @list, @latest_versions = [], []

  class << self
    attr_reader :list, :latest_versions

    # Scans the RUBYLIB (unless overridden via path), for rules subclasses and
    # requires them.  Looks for files that match:
    #
    #   <Dir from path>/**/rules/**/*.rb
    #

    def require_all( path=$: )
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
    end

    # Find a Rules instance.  Takes a string and returns the subclass.  This
    # method will try a couple transformations on the string to find a match
    # in Rules.latest_versions.  For example, "keryo_pente" will find 
    # KeryoPente.  If a version is given, Rules.list is searched for an 
    # exact match.

    def Rules.find( name, version=nil )
      return name if name.kind_of?( Rules ) && version.nil?

      if version.nil?
        Rules.latest_versions.each do |r|
          return r if name == r ||
                      name.to_s.downcase == r.class_name.downcase ||
                      name.to_s.downcase == r.to_snake_case
        end
      else
        Rules.list.each do |r|
          return r if (name == r ||
                       name.to_s.downcase == r.class_name.downcase ||
                       name.to_s.downcase == r.to_snake_case) &&
                      version == r.version
        end

        return Rules.find( name ) # couldn't find the exact version
                                  # try the most recent version
      end
      nil
    end

  end

  # Build a Rules object.  Code in Rules.create's block is executed in the
  # context of a Builder object.

  class Builder
    def initialize( rules )
      @rules = rules
    end

    # Sets Rules instance variables.  The value of the instance variable
    # depends on the number of arguments:
    #
    #   name "Tic Tac Toe"        <=   @name = "Tic Tac Toe"
    #   random                    <=   @random = true
    #   players :black, :white    <=   @players = [:black, :white]
    #

    def method_missing( m, *args )
      v = true       if args.length == 0
      v = args.first if args.length == 1
      v ||= args

      @rules.instance_variable_set( "@#{m}", v )
    end

    # The code in the given block is used to create a subclass of Position.
    #
    #   position do
    #     # ...
    #   end
    #
    # Is (mostly) the equivalent of:
    #
    #   class AnonymousSubClass < Position
    #     # ...
    #   end
    #
    # Yes, the position subclass is anonymous.  A new instance of the subclass
    # can be had by calling Rules#new.  If you must get access to the position
    # class itself, try Rules#position_class.

    def position( &block )
      class_name = "#{@rules.class_name}_#{@rules.version.gsub( /\./, '_' )}"
      klass = Positions.const_set( class_name, Class.new( Position ) )

      klass.class_eval( &block )
      klass.instance_variable_set( "@rules", @rules )

      # Wrap (replace) #move?, #moves, and #apply!

      klass.class_eval do
        if instance_method( :move? ).arity != -2
          alias_method :__original_move?, :move?
          alias_method :move?, :__move?
          public :move?
          private :__original_move?
        end

        if instance_method( :moves ).arity != -1
          alias_method :__original_moves, :moves
          alias_method :moves, :__moves
          public :moves
          private :__original_moves
        end

        if instance_method( :apply! ).arity != -2
          alias_method :__original_apply!, :apply!
          alias_method :apply!, :__apply!
          public :apply!
          private :__original_apply!
        end
      end

      # caching

      @rules.cached.each do |m|
        if m == :init
          klass.class_eval { prototype }
        else
          klass.extend Memoizable
          klass.immutable_memoize m
        end
      end

      klass
    end

    # Create's an Option.
    #
    # For example:
    #
    #   Rules.create( "TicTacToe" ) do
    #     option :board_size, :default => 12, :values => [10, 11, 12, 13]
    #   end
    #
    # The option can be accessed like so:
    #
    #   TicTacToe.options[:board_size]  => #<Option ...>
    #
    # See Option.

    def option( name, options )
      opts = @rules.instance_variable_get( "@options" )
      opts[name] = Option.new( name, options )
      @rules.instance_variable_set( "@options", opts )

      defaults = @rules.instance_variable_get( "@defaults" )
      defaults[name] = opts[name].default
      @rules.instance_variable_set( "@defaults", defaults )
    end

    # Specify which methods should be cached.
    #
    # For example:
    #
    #   Rules.create( "AmericanCheckers" ) do
    #     cache :init, :moves, :final?
    #   end
    #

    def cache( *args )
      args.delete( :init ) if @rules.random?
      @rules.instance_variable_set( "@cached", args )
    end

  end

end

