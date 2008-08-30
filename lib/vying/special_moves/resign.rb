# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class Move::Resign < SpecialMove

  def self.[]( s )
    new( $1 ) if s =~ /(\w+)_resigns$/
  end

  def initialize( by )
    @move, @by = "#{by}_resigns", by.to_sym
  end

  def valid_for?( game, player=nil )
    (player.nil? || player == by) && game.player?( by ) && 
    ! (game.draw_offered? || game.undo_requested?)
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
      @resigned_by = player
    end

    def resigned?;                     true;                            end
    def resigned_by;                   @resigned_by;                    end
    def resigned_by?( player );        @resigned_by == player;          end
    def final?;                        true;                            end
    def winner?( player );             player != @resigned_by;          end
    def loser?( player );              player == @resigned_by;          end
    def draw?;                         false;                           end
    def moves( player=nil );           [];                              end
    def move?( move, player=nil );     false;                           end
    def has_moves;                     [];                              end
  end
end

