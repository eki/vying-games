# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/connect6/connect6'

class CapellaBot < Bot
  class Connect6 < Bot
    include AlphaBeta
    include Connect6Strategies

    difficulty :hard

    attr_reader :leaf, :nodes

    def initialize( *args )
      super
      @leaf, @nodes = 0, 0
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      @leaf, @nodes = 0, 0
      score, move = best( analyze( position, player ) )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
      move
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?

      eval_player_threats( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 2
    end

    def prune( position, player, moves )
      n = (position.board.occupied[:white] || []).length < 20 ? super : nil

      if position.board.threats.length > 0
         original_moves = moves
         threats = position.board.threats.sort_by { |t| t.degree }

         important = []
         p_important = threats.select { |t| t.degree < 3 && t.player == player }
         o_important = threats.select { |t| t.degree < 3 && t.player != player }

         threes = threats.select { |t| t.degree == 3 && t.player == player }
         twos   = threats.select { |t| t.degree == 4 && t.player == player }

         moves3 = threes.map { |t| t.empty_coords.map { |c| c.to_s } }
         moves3.flatten!

         moves2 = twos.map { |t| t.empty_coords.map { |c| c.to_s } }
         moves2.flatten!

         important += p_important[0..1]
         important += o_important[0..1]

         unless important.empty?
           moves = important.map { |t| t.empty_coords.map { |c| c.to_s } }
           moves.flatten!
           moves  &= n if n
           moves3 &= n if n
           moves2 &= n if n

           moves3 -= moves
           moves2 -= moves

           moves << moves3[rand(moves3.length)] unless moves3.empty?
           moves << moves2[rand(moves2.length)] unless moves2.empty?
           moves << n.find { |o| !moves.include?( o ) } if n

           return moves
         else
           threats2 = threats.select { |t| t.player == player }

           unless threats2.empty?
             moves = threats2.map { |t| t.empty_coords.map { |c| c.to_s } }
             moves.flatten!
             moves = moves.sort_by do |move|
               moves.select { |m| m == move }.length
             end
             moves = moves.uniq.reverse!

             moves  &= n if n
             moves3 &= n if n
             moves2 &= n if n

             moves = moves[0..2]

             moves3 -= moves
             moves2 -= moves

             moves << moves3[rand(moves3.length)] unless moves3.empty?
             moves << moves2[rand(moves2.length)] unless moves2.empty?
             moves << n.find { |m| !moves.include?( m ) } if n

             return moves
           else
             moves = threats.map { |t| t.empty_coords.map { |c| c.to_s } }
             moves.flatten!
             moves = moves.sort_by do |move|
               moves.select { |m| m == move }.length
             end
             moves = moves.uniq.reverse!

             if n
               moves &= n
             else
               nmoves = 
                 moves.select { |move| position.board.has_neighbor? move }
               moves = nmoves unless nmoves.empty?
             end

             return moves[0..3]
           end
         end
      else
        return n.sort_by { rand }[0..2] if n
        return moves.sort_by { rand }[0..2]
      end
    end

  end
end

