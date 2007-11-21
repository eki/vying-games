require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/phutball/phutball'

class CapellaBot < Bot
  class Phutball < Bot
    include AlphaBeta
    include PhutballStrategies

    difficulty :easy

    attr_reader :leaf, :nodes

    def initialize
      super
      @leaf, @nodes = 0, 0
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      @leaf, @nodes = 0, 0
      score, move = fuzzy_best( analyze( position, player ), 1 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
      move
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?
    
      eval_distance( position, player ) * 100 + eval_men( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 1
    end

    def prune( position, player, moves )
      b = position.board


      ball = position.board.occupied[:white].first
      men = position.board.occupied[:black] || []

      keep = []

      unless moves.include?( "pass" )
        b.coords.neighbors( ball ).each do |nc|
          if b[nc].nil? && ( (player == :ohs && nc.y < ball.y) ||
                             (player == :eks && nc.y > ball.y) )
            keep << nc
          end
        end

        men.each do |m| 
          if (player == :ohs && m.y < ball.y) ||
             (player == :eks && m.y > ball.y)
            b.coords.neighbors( m ).each do |nc|
              keep << nc if b[nc].nil?
            end
          end
        end
      else
        keep << "pass"
      end

      keep.uniq!

      keep.map! { |c| c.to_s }

      moves.each do |move|
        keep << move if move.to_coords.length == 2
      end

      keep
    end

  end
end

