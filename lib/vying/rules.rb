
# frozen_string_literal: true

module Vying

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
  #   #score      - if the game has a score, what is the score for this
  #                 position?
  #   #hash       - hash the position
  #

  class Rules
    # private :new   # TODO

    attr_reader :class_name, :name, :version, :players, :options, :defaults,
                :misere_rules

    def initialize(class_name)
      @class_name, @options, @defaults, @cached = class_name, {}, {}, []
    end

    class << self

      # Create a new Rules instance.  This takes a class name and block.
      # Example:
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

      def create(class_name, &block)
        rules = new(class_name)
        builder = Builder.new(rules)
        builder.instance_eval(&block)

        rules.instance_variables.each do |iv|
          rules.instance_variable_get(iv).freeze
        end

        unless rules.broken?
          Vying.const_set(class_name, rules)

          unless Kernel.const_defined?(class_name)
            Kernel.const_set(class_name, rules)
          end
        end

        list_rules(rules)

        rules
      end

      # Creates rules and position classes for the misere variation of the
      # given rules.  Under misere rules the winner? and loser? methods are
      # inverted, but the rules are otherwise unchanged.  If, for example, the
      # rules are DotsAndBoxes, the misere rules will be put in
      # MisereDotsAndBoxes.  The name will also be prefixed so,
      # "Dots and Boxes" becomes "Misere Dots and Boxes".  In DotsAndBoxes the
      # player with the highest score will be the winner, in MisereDotsAndBoxes
      # the player with the lowest score will be the winner.
      #
      # This can be triggered with Rules.create like so:
      #
      #   Rules.create( "DotsAndBoxes" ) do
      #
      #     misere
      #
      #   end
      #
      # Alternately, you can call this on an existing Rules object that does
      # not already have misere rules:
      #
      #  >> Rules.create_misere( Othello )
      #  => #<Rules name: 'Misere Othello', version: 1.0.0>
      #

      def create_misere(rules)
        return rules.misere_rules    if rules.misere_rules
        return rules.inverted_rules  if rules.misere?

        mrs = rules.dup

        mrs.instance_variable_set('@class_name', "Misere#{rules.class_name}")
        mrs.instance_variable_set('@name', "Misere #{rules.name}")
        mrs.instance_variable_set('@inverted_rules', rules)

        unless mrs.broken?
          Kernel.const_set(mrs.class_name, mrs)
        end

        list_rules(mrs)

        class_name = "#{mrs.class_name}_#{mrs.version.tr('.', '_')}"
        klass = Positions.const_set(class_name,
          Class.new(rules.position_class))

        klass.instance_variable_set('@inverted_rules', rules)
        klass.instance_variable_set('@rules', mrs)

        if rules.highest_score_determines_winner?

          mrs.instance_variable_set('@highest_score_determines_winner', nil)
          mrs.instance_variable_set('@lowest_score_determines_winner', true)

        elsif rules.lowest_score_determines_winner?

          mrs.instance_variable_set('@highest_score_determines_winner', true)
          mrs.instance_variable_set('@lowest_score_determines_winner', nil)

        else

          klass.class_eval do
            alias_method :__original_winner?, :winner?
            alias_method :__original_loser?,  :loser?

            if !Rules.overrides.include?("#{rules.position_class}#loser?")

              def winner?(player)
                loser?(opponent(player))
              end

            else

              def winner?(player)
                __original_loser?(player)
              end

            end

            def loser?(player)
              __original_winner?(player)
            end
          end

        end

        rules.instance_variable_set('@misere_rules', mrs)

        mrs
      end

      def overrides
        @overrides ||= []
      end

      # Add the given Rules object to Rules.list.

      def list_rules(rules)
        list << rules

        in_list = false
        latest_versions.length.times do |i|
          next unless latest_versions[i].class_name == rules.class_name
          if rules.version > latest_versions[i].version
            latest_versions[i] = rules
          end
          in_list = true
        end

        latest_versions << rules unless in_list
      end

      private :list_rules
    end

    # Returns a starting position for these rules.  The given options are
    # validated against #options.

    def new(seed=nil, opts={})
      if seed.class == Hash
        seed, opts = nil, seed
      end

      opts = defaults.dup.merge!(opts)
      if validate(opts)
        opts.each do |name, value|
          opts[name] = options[name].coerce(value)
        end
      end

      position_class.new(seed, opts)
    end

    # Return a list of all available versions of these rules.

    def versions
      Rules.list.select { |r| r.class_name == class_name }.
        map(&:version).
        sort
    end

    # Returns the Position subclass used by these rules.

    def position_class
      pkn = "#{class_name}_#{version.tr('.', '_')}"
      Positions.const_get(pkn)
    end

    # Returns a list of all Position subclasses used by every available version
    # of these rules.

    def position_classes
      versions.map { |v| Rules.find(class_name, v) }.
        map(&:position_class)
    end

    # Validate options that can be passed to Rules#new.  Checks that all
    # options are present, and then passes the value onto Option#validate.
    # Will raise an exception if anything is invalid.

    def validate(opts)
      diff = opts.keys - options.keys

      if diff.length == 1
        raise "#{diff.first} is not a valid option for #{name}"
      elsif !diff.empty?
        raise "#{diff.inspect} are not valid options for #{name}"
      end

      opts.all? do |name, value|
        options[name].validate(value)
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

    def player?(p)
      players.include?(p)
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

    # Is the game defined by these rules deterministic?  That is, the outcome is
    # determined solely by the players -- chance does not play a role.  It is
    # possible for a game to have a random opening but otherwise be
    # deterministic.  For example, Ataxx starts with a random (but fair) board,
    # but the game play is itself deterministic.  A game like Pig which is
    # strongly influenced by the roll of dice is nondeterministic and should
    # return false.
    #
    # This property can be set like this:
    #
    #   Rules.create( "Ataxx" ) do
    #     random
    #     deterministic
    #   end
    #
    # Note, if you don't set 'random' you don't need to set 'deterministic'.
    # If you don't ask for a random number generator the game is assumed to be
    # deterministic.

    def deterministic?
      !!(!random? || @deterministic)
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

    def cached?(m)
      @cached.include?(m)
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

    def score_determines_outcome?
      @highest_score_determines_winner || @lowest_score_determines_winner
    end

    # Is this game's winner determined by (the highest) score?  Setting this
    # causes the default implementation of #winner?, #loser?, and #draw? to
    # use score.  See score_determines_outcome?
    #
    # This is set with:
    #
    #   Rules.create( "Hexxagon" ) do
    #     highest_score_determines_winner
    #   end
    #

    def highest_score_determines_winner?
      @highest_score_determines_winner
    end

    # Is this game's winner determined by (the lowest) score?  Setting this
    # causes the default implementation of #winner?, #loser?, and #draw? to
    # use score.  See score_determines_outcome?
    #
    #   Rules.create( "..." ) do
    #     lowest_score_determines_winner
    #   end
    #

    def lowest_score_determines_winner?
      @lowest_score_determines_winner
    end

    # Do these rules define a score?

    def has_score?
      position_class.instance_methods.include?(:score)
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

    # Is this the misere version of another Rules object?  That is, were these
    # rules created with the Rules.create_misere method?

    def misere?
      !!@inverted_rules
    end

    # Do these rules use sealed moves (aka simultaneous moves)?  More than one
    # player can move at a time, the moves are sealed until all (or some subset
    # of more than one player) have moved.  This result is based on the arity
    # of the Position subclass' #moves and #apply! methods (if they take a
    # player parameter it's assumed the rules allow for sealed moves).

    def sealed_moves?
      return @sealed_moves if @sealed_moves

      if position_class.private_instance_methods.include?(:__original_moves)
        original_moves = position_class.instance_method(:__original_moves)
      end

      if position_class.private_instance_methods.include?(:__original_apply!)
        original_apply = position_class.instance_method(:__original_apply!)
      end

      @sealed_moves = (!original_moves || original_moves.arity == 1) &&
                      (!original_apply || original_apply.arity == 2)
    end

    # The prefered notation for this game.

    attr_reader :notation

    # Terse inspect string for a Rules instance.

    def inspect
      "#<Rules name: '#{name}', version: #{version}>"
    end

    # TODO: Clean this up a little more.

    def method_missing(m, *args)
      iv = instance_variable_get("@#{m}")
      iv || super
    end

    # TODO: Clean this up a little more.

    def respond_to_missing?(m, include_all)
      super || !!instance_variable_defined?("@#{m}")
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
        s.gsub!(/(.)([A-Z])/) { "#{Regexp.last_match(1)}_#{Regexp.last_match(2).downcase}" }
      end
      s.downcase
    end

    # Shorter alias for Rules#to_snake_case

    alias to_sc to_snake_case

    # Only need to dump the name, version.

    def _dump(depth=-1)
      Marshal.dump([class_name, version])
    end

    # Load mashalled data.

    def self._load(s)
      class_name, version = Marshal.load(s)
      Rules.find(class_name, version)
    end

    @list, @latest_versions = [], []

    class << self
      attr_reader :list, :latest_versions

      # Require all the rules.
      def require_all
        Dir.glob("#{Vying.root}/lib/vying/rules/**/*.rb") do |f|
          require f.to_s
        end
      end

      # Find a Rules instance.  Takes a string and returns the subclass.  This
      # method will try a couple transformations on the string to find a match
      # in Rules.latest_versions.  For example, "keryo_pente" will find
      # KeryoPente.  If a version is given, Rules.list is searched for an
      # exact match.

      def Rules.find(name, version=nil)
        return name if name.kind_of?(Rules) && version.nil?

        if version.nil?
          Rules.latest_versions.each do |r|
            return r if name == r ||
                        name.to_s.casecmp(r.class_name).zero? ||
                        name.to_s.downcase == r.to_snake_case
          end
        else
          Rules.list.each do |r|
            return r if (name == r ||
                         name.to_s.casecmp(r.class_name).zero? ||
                         name.to_s.downcase == r.to_snake_case) &&
                        version == r.version
          end

          return Rules.find(name) # couldn't find the exact version
          # try the most recent version
        end
        nil
      end

    end

    # Build a Rules object.  Code in Rules.create's block is executed in the
    # context of a Builder object.

    class Builder
      def initialize(rules)
        @rules = rules
      end

      # Sets Rules instance variables.  The value of the instance variable
      # depends on the number of arguments:
      #
      #   name "Tic Tac Toe"        <=   @name = "Tic Tac Toe"
      #   random                    <=   @random = true
      #   players :black, :white    <=   @players = [:black, :white]
      #

      def method_missing(m, *args) # rubocop:disable Style/MethodMissing
        v = true       if args.empty?
        v = args.first if args.length == 1
        v ||= args

        @rules.instance_variable_set("@#{m}", v)
      end

      def respond_to_missing?(m, include_all)
        true # Wow, really? This is what we're doing?
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
      # Yes, the position subclass is anonymous.  A new instance of the
      # subclass can be had by calling Rules#new.  If you must get access to
      # the position class itself, try Rules#position_class.

      def position(&block)
        class_name = "#{@rules.class_name}_#{@rules.version.tr('.', '_')}"
        klass = Positions.const_set(class_name, Class.new(Position))

        # Record the methods added to the Position subclass.

        klass.class.class_eval do
          def method_added(name)
            if Position.method_defined?(name)
              Rules.overrides << "#{self}##{name}"
            end
          end
        end

        # Execute the position block

        klass.class_eval(&block)

        klass.instance_variable_set('@rules', @rules)

        # Wrap (replace) #move?, #moves, and #apply!

        klass.class_eval do
          if instance_method(:move?).arity != -2
            alias_method :__original_move?, :move?
            alias_method :move?, :__move?
            public :move?
            private :__original_move?
          end

          if instance_method(:moves).arity != -1
            alias_method :__original_moves, :moves
            alias_method :moves, :__moves
            public :moves
            private :__original_moves
          end

          if instance_method(:apply!).arity != -2
            alias_method :__original_apply!, :apply!
            alias_method :apply!, :__apply!
            public :apply!
            private :__original_apply!
          end
        end

        # Stop recording added methods.

        klass.class.class_eval do
          def method_added(name)
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

        Rules.create_misere(@rules) if @misere

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

      def option(name, options)
        opts = @rules.instance_variable_get('@options')
        opts[name] = Option.new(name, options)
        @rules.instance_variable_set('@options', opts)

        defaults = @rules.instance_variable_get('@defaults')
        defaults[name] = opts[name].default
        @rules.instance_variable_set('@defaults', defaults)
      end

      # Specify which methods should be cached.
      #
      # For example:
      #
      #   Rules.create( "AmericanCheckers" ) do
      #     cache :init, :moves, :final?
      #   end
      #

      def cache(*args)
        args.delete(:init) if @rules.random?
        @rules.instance_variable_set('@cached', args)
      end

      # Automatically create the misere version of these rules.

      def misere
        @misere = true
      end
    end

  end
end

# Make Rules a top-level constant

Rules = Vying::Rules
