# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying
  class Move::CancelDraw < SpecialMove

    def self.[]( s )
      new if s =~ /^cancel_draw$/
    end

    def initialize
      @move = "cancel_draw"
    end

    def valid_for?( game, player=nil )
      game.draw_offered? && (player.nil? || game.draw_offered_by?( player ))
    end

    def self.generate_for( game, player=nil )
      m = new
      m if m.valid_for?( game, player )
    end

    def before_apply( game )
      game.cancel_draw
    end

  end
end

