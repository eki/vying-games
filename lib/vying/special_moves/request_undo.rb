# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class Move::RequestUndo < SpecialMove

  def self.[]( s )
    new( $1 ) if s =~ /^undo_requested_by_(\w+)/
  end

  def initialize( by )
    @move, @by = "undo_requested_by_#{by}", by.to_sym
  end

  def valid_for?( game, player=nil )
    if (player.nil? || player == by) && game.player?( by )
      last = game.history.moves.last

      last && ! last.special? && ! Move::Undo["undo"].valid_for?( game )
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
    def apply_special( move, player )
        @requested_by = player
    end

    def undo_requested?;               true;                            end
    def undo_requested_by;             @requested_by;                   end
    def undo_requested_by?( player );  @requested_by == player;         end
    def final?;                        false;                           end
    def moves( player=nil );           [];                              end
    def move?( move, player=nil );     false;                           end
    def has_moves;                     players - [@requested_by];       end
  end
end

