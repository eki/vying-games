# frozen_string_literal: true

# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/games'

module Vying::Games
  class Move::RejectUndo < SpecialMove

    def self.[](s)
      new if s =~ /^reject_undo$/
    end

    def initialize
      @move = 'reject_undo'
    end

    def valid_for?(game, player=nil)
      game.undo_requested? && (player.nil? ||
      !(game.undo_requested_by?(player) || game.undo_accepted_by?(player)))
    end

    def self.generate_for(game, player=nil)
      m = new
      m if m.valid_for?(game, player)
    end

    def before_apply(game)
      game.reject_undo
    end

  end
end
