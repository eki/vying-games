# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying
  class Move::Draw < SpecialMove

    def self.[]( s )
      new if s =~ /^draw$/
    end

    def initialize
      @move = "draw"
    end

    def valid_for?( game, player=nil )
      player.nil? && game.allow_draws_by_agreement?
    end

    def self.generate_for( game, player=nil )
      player.nil? && game.allow_draws_by_agreement? ? [new] : []
    end

    module PositionMixin
      def apply_special_move( move, player )
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
  end
end

