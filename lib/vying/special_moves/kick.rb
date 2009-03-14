# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying
  class Move::Kick < SpecialMove
    attr_reader :target

    def self.[]( s )
      new( $1 ) if s =~ /^kick_(\w+)$/
    end

    def initialize( target )
      @move, @target = "kick_#{target}", target.to_sym
    end

    def valid_for?( game, player=nil )
      game.unrated? && 
      (player.nil? || 
        (player != target && game.player?( player ) && game[player].user)) && 
      (game.player?( target ) && game[target].user)
    end

    def self.generate_for( game, player=nil )
      ms = []
      game.player_names.each do |p|
        m = new( p )
        ms << m if m.valid_for?( game, player )
      end
      ms
    end

    def before_apply( game )
      game.kick( target )
    end

  end
end

