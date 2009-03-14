# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying
  class Move::Swap < SpecialMove

    def self.[]( s )
      new if s =~ /^swap$/
    end

    def initialize
      @move = "swap" 
    end

    def valid_for?( game, player=nil )
      hm = game.has_moves

      game.pie_rule? && hm.first != game.player_names.first &&
      game.history.last_turn.length == game.history.moves.length &&
      (player.nil? || hm.include?( player ))
    end

    def self.generate_for( game, player=nil )
      m = new
      m.valid_for?( game, player ) ? [m] : []
    end

    def before_apply( game )
      game.swap
    end

    module PositionMixin
      def apply_special_move( move, player )
      end
    end
  end
end

