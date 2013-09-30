# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying

  # Move is used solely by history.  It should be compatible with Game / 
  # Position but as a rule, you want to use Strings to represent moves.  
  # However, be aware that the values in History#moves will be Move objects.
  #
  # Move#to_s will give you the String representation of the move.
  # Move#by will give you the player name symbol (not a Player object)
  # Move#at will give you the Time the move was made (if it's known)
  #

  class Move

    attr_reader :by, :at

    # Initialize a Move with the String representation, the player who made the
    # move, and the time the move was made.

    def initialize( m, by=nil )
      @move, @by = m, by
      @move.deep_dup.freeze
    end

    # Returns a timestamped copy of this Move.  (Sets #at to the given time or
    # Time.now)

    def stamp( t=Time.now )
      (m = dup).instance_variable_set( "@at", t )
      m
    end

    # Moves are considered to be equal if they share the same #to_s and #by.
    # Note:  For convenience sake, if compared to an object that is *not* a 
    # Move, the values of #to_s are compared.  So:
    #
    #   > Move.new( "a1", :black ) == Move.new( "a1", :white )
    #   => false
    #
    #   > Move.new( "a1", :black ) == "a1"
    #   => true
    #

    def eql?( o )
      o.kind_of?( Move ) ? to_s == o.to_s && by == o.by : to_s == o.to_s
    end

    # See #eql?

    def ==( o )
      eql?( o )
    end

    # Allow sorting moves (by to_s).

    def <=>( o )
      to_s <=> o.to_s
    end

    # Hash based on the move string and player symbol.

    def hash
      [@move, @by].hash
    end

    # Returns the string representation of the move.  This can be passed to
    # Game / Position methods that expect a move.  Note, this isn't strictly
    # necessary as those methods typically call #to_s on whatever object they
    # are given.

    def to_s
      @move.to_s
    end

    # More detailed inspect string.

    def inspect
      by ? "#{@move}:#{by}" : "#{@move}"
    end

    # Is this a special move?

    def special?
      false
    end

    # Apply this move to the given position.  If necessary a module will be
    # mixed into a dup of the position (and Position#apply_special will be
    # called.  For example, of such a module see TimeExceeded.  If no module
    # is mixed in (a normal move) then Position#apply is called.  The resulting
    # position is returned.

    def apply_to_position( p )
      p.apply( @move, by )
    end

    def apply_to_game( g )
      g.history.append( self )
    end

    def apply_to( o )
      case o
        when Position  then apply_to_position( o )
        when Game      then apply_to_game( o )
      end
    end

    def valid_for?( game, player=nil )
      (player.nil? || player == by) && game.move?( @move, by )
    end

    # Move's respond to any methods the underlying move object responds to.

    def respond_to?( m, include_all=false )
      super || @move.respond_to?( m, include_all )
    end

    # Forward method calls to the underlying move object.  This is mostly useful
    # for conversion methods.  For example:
    #
    #   > Move.new( 3, :left ).to_i
    #   => 3
    #
    # Or, methods that are shared by String and the underlying object:
    #
    #   > Move.new( Coord[:a1], :black ).x
    #   => 0
    #
    #   > Move.new( "a1", :black ).x
    #   => 0
    #

    def method_missing( m, *args )
      @move.respond_to?( m ) ? @move.send( m, *args ) : super
    end

    # Can't fall back on method_missing to forward calls to #y because it's 
    # (stupidly) defined by Kernel.

    def y
      method_missing( :y )
    end

    def _dump( depth=-1 )
      Marshal.dump( [@move, by] )
    end

    def self._load( str )
      new( * Marshal.load( str ) )
    end

    class << self
      extend Memoizable
      memoize :new
    end
  end
end

