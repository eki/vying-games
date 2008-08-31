# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# This is the super class for all special moves.  Unlike normal moves, special
# moves act on Games and / or Positions, rather than just Positions.

class SpecialMove < Move

  def special?
    true
  end

  def inspect
    @move.to_s
  end

  def effects_history?
    self.class.const_defined?( :PositionMixin )
  end

  def apply_to_position( p )
    p = p.dup
    p.extend self.class.const_get( :PositionMixin )
    p.apply_special( @move, by )
    p
  end

  def apply_to_game( g )
    before_apply( g )

    if effects_history?
      g.history.append( self )
    else
      g.history.instance_variable_set( "@last_move_at", Time.now )
    end

    after_apply( g )
  end

  def before_apply( game )

  end

  def after_apply( game )

  end

  class << self

    # Scans the RUBYLIB (unless overridden via path), for notation subclasses
    # and requires them.  Looks for files that match:
    #
    #   <Dir from path>/**/notations/*.rb
    #

    def require_all( path=$: )
      required = []
      path.each do |d|
        Dir.glob( "#{d}/**/special_moves/*.rb" ) do |f|
          f =~ /(.*)\/special_moves\/([\w\d]+\.rb)$/
          if ! required.include?( $2 ) && !f["_test"]
            required << $2
            require "#{f}"
          end
        end
      end
    end

    @@special_moves_list, @@instance_cache = [], {}

    # When a subclass extends SpecialMove it's added to @@special_move_list.

    def inherited( child )
      @@special_moves_list << child
    end

    def list
      @@special_moves_list
    end

    def []( s )
      return s                    if s.kind_of?( SpecialMove )
      return @@instance_cache[s]  if @@instance_cache[s]

      list.each { |sm| m = sm[s]; return @@instance_cache[s] = m if m }; nil
    end

    def generate_for( game, player=nil ) 
      list.map { |sm| sm.generate_for( game, player ) }.flatten.compact
    end

    private :new
  end
end

