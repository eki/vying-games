# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

module PhutballStrategies

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

end

