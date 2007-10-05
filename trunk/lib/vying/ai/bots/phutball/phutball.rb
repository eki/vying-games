require 'vying/ai/bot'

module AI::Phutball

  def eval_distance( position, player )
    ball = position.board.occupied[:white].first
    score = 0

    if player == :ohs
      score = 11 - ball.y
    else
      score = ball.y - 11
    end

    score
  end

  def eval_men( position, player )
    ball = position.board.occupied[:white].first
    men = position.board.occupied[:black]

    score = 0
    intervals = []

    men.each do |m|
      if player == :ohs
        score = 11 - m.y
      else
        score = m.y - 11
      end

      if (player == :ohs && m.y < ball.y) ||
         (player == :eks && m.y > ball.y)
        intervals << (ball.y - m.y).abs
      end
    end

    intervals.each do |i|
      score += case i
        when 0..1 then 20
        when 2..3 then  8
        when 4..5 then  6
        else 0
      end
    end

    score
  end

  def eval_random( position, player )
    rand( 100 ) - 50
  end

  module Bot
    include AI::Phutball
    include AlphaBeta

    attr_reader :nodes, :leaf

    def initialize
      super
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

      eval( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 2
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

