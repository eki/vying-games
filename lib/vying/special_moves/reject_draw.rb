# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'


class Move::RejectDraw < SpecialMove

  def self.[]( s )
    new if s =~ /^reject_draw$/
  end

  def initialize
    @move = "reject_draw"
  end

  def valid_for?( game, player=nil )
    game.draw_offered? && (player.nil? || 
    ! (game.draw_offered_by?( player ) || game.draw_accepted_by?( player )))
  end

  def self.generate_for( game, player=nil )
    m = new
    m if m.valid_for?( game, player )
  end

  def before_apply( game )
    game.reject_draw
  end

end

