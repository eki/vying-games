# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class Move::AcceptDraw < SpecialMove

  def self.[]( s )
    new( $1 ) if s =~ /^draw_accepted_by_(\w+)/
  end

  def initialize( by )
    @move, @by = "draw_accepted_by_#{by}", by.to_sym
  end

  def valid_for?( game, player=nil )
    (player.nil? || player == by) && game.player?( by ) &&
    game.draw_offered? && 
    ! (game.draw_offered_by?( by ) || game.draw_accepted_by?( by ))
  end

  def self.generate_for( game, player=nil )
    ms = []
    game.player_names.each do |p|
      m = new( p )
      ms << m if m.valid_for?( game, player )
    end
    ms
  end

  def after_apply( game )
    game.accept_draw
  end


  module PositionMixin
    def apply_special_move( move, player )
      @accepted_by ||= []
      @accepted_by << player
      @waiting_for = players - [@offered_by] - @accepted_by
    end

    def draw_offered?;                 true;                            end
    def draw_offered_by;               @offered_by;                     end
    def draw_offered_by?( player );    @offered_by == player;           end
    def draw_accepted_by?( player );   @accepted_by.include?( player ); end
    def final?;                        false;                           end
    def moves( player=nil );           [];                              end
    def move?( move, player=nil );     false;                           end
    def has_moves;                     @waiting_for;                    end
  end
end

