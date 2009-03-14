# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying
  class Move::OfferDraw < SpecialMove

    def self.[]( s )
      new( $1 ) if s =~ /^draw_offered_by_(\w+)/
    end

    def initialize( by )
      @move, @by = "draw_offered_by_#{by}", by.to_sym
    end

    def valid_for?( game, player=nil )
      if game.allow_draws_by_agreement? 
        last = game.history.moves.last

        (player.nil? || player == by) && game.player?( by ) &&
        ! (last && last.special?) 
      end
    end

    def self.generate_for( game, player=nil )
      ms = []
      game.player_names.each do |p|
        m = new( p )
        ms << m if m.valid_for?( game, player )
      end
      ms
    end

    module PositionMixin
      def apply_special_move( move, player )
        @offered_by = player
      end

      def draw_offered?;                 true;                            end
      def draw_offered_by;               @offered_by;                     end
      def draw_offered_by?( player );    @offered_by == player;           end
      def final?;                        false;                           end
      def moves( player=nil );           [];                              end
      def move?( move, player=nil );     false;                           end
      def has_moves;                     players - [@offered_by];         end
    end
  end
end

