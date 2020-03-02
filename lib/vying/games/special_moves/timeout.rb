# frozen_string_literal: true

# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/games'

module Vying::Games
  class Move::Timeout < SpecialMove

    def self.[](s)
      new(Regexp.last_match(1)) if s =~ /^time_exceeded_by_(\w+)/
    end

    def initialize(by)
      @move, @by = "time_exceeded_by_#{by}", by.to_sym
    end

    def valid_for?(game, player=nil)
      player.nil? && game.player?(by)
    end

    def self.generate_for(game, player=nil)
      ms = []
      game.player_names.each do |p|
        m = new(p)
        ms << m if m.valid_for?(game, player)
      end
      ms
    end

    module PositionMixin
      def apply_special_move(move, player)
        @exceeded_by = player
      end

      def time_exceeded?
        true
      end

      def time_exceeded_by
        @exceeded_by
      end

      def time_exceeded_by?(player)
        @exceeded_by == player
      end

      def final?
        true
      end

      def winner?(player)
        player != @exceeded_by
      end

      def loser?(player)
        player == @exceeded_by
      end

      def draw?
        false
      end

      def moves(player=nil)
        []
      end

      def move?(move, player=nil)
        false
      end

      def has_moves
        []
      end
    end
  end
end
