# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class Move::Undo < SpecialMove

  def self.[]( s )
    new if s =~ /^undo$/
  end

  def initialize
    @move = "undo"
  end

  def valid_for?( game, player=nil )
    last = game.history.moves.last

    unless last.nil? || last.special?
      hm = game.has_moves

      hm.length == 1 && hm.first == last.by &&
      (player.nil? || player == hm.first)
    end
  end

  def self.generate_for( game, player=nil )
    m = new
    m.valid_for?( game, player ) ? [m] : []
  end

  def before_apply( game )
    game.undo
  end

end

