# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class Move::AcceptUndo < SpecialMove

  def self.[]( s )
    new( $1 ) if s =~ /^undo_accepted_by_(\w+)/
  end

  def initialize( by )
    @move, @by = "undo_accepted_by_#{by}", by.to_sym
  end

  def valid_for?( game, player=nil )
    (player.nil? || player == by) && game.player?( by ) &&
    game.undo_requested? && 
    ! (game.undo_requested_by?( by ) || game.undo_accepted_by?( by ))
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
    game.accept_undo
  end

  module PositionMixin
    def apply_special( move, player )
      @accepted_by ||= []
      @accepted_by << player
      @waiting_for = players - [@requested_by] - @accepted_by
    end

    def undo_requested?;               true;                            end
    def undo_requested_by;             @requested_by;                   end
    def undo_requested_by?( player );  @requested_by == player;         end
    def undo_accepted_by?( player );   @accepted_by.include?( player ); end
    def final?;                        false;                           end
    def moves( player=nil );           [];                              end
    def move?( move, player=nil );     false;                           end
    def has_moves;                     @waiting_for;                    end
  end
end

