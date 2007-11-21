
module Connect6Strategies

  PATTERNS = { [:black, :black, :black] => 10,
               [:black, :black, nil   ] =>  2,
               [nil,    :black, :black] =>  2,
               [nil,    :black, nil   ] =>  0,
               [nil,    :black, :white] =>  0,
               [:white, :black, nil   ] =>  0,
               [:white, :black, :white] => -1,
               [:black, :black, :white] => -10,
               [:white, :black, :black] => -10,
               [:white, :white, :white] => 10,
               [:white, :white, nil   ] =>  2,
               [nil,    :white, :white] =>  2,
               [nil,    :white, nil   ] =>  0,
               [nil,    :white, :black] =>  0,
               [:black, :white, nil   ] =>  0,
               [:black, :white, :black] => -1,
               [:white, :white, :black] => -10,
               [:black, :white, :white] => -10 }

  def eval_neighbors( position, player )
    opp = player == :black ? :white : :black
    score = 0

    b = position.board

    b.occupied[player].each do |c|
      score += score_pattern( b, c, [:n,:s] )
      score += score_pattern( b, c, [:e,:w] )
      score += score_pattern( b, c, [:ne,:sw] )
      score += score_pattern( b, c, [:nw,:se] )
    end

    b.occupied[opp].each do |c|
      score -= score_pattern( b, c, [:n,:s] )
      score -= score_pattern( b, c, [:e,:w] )
      score -= score_pattern( b, c, [:ne,:sw] )
      score -= score_pattern( b, c, [:nw,:se] )
    end

    score
  end

  def eval_threats( position, player )
    score = 0

    position.board.threats.each do |t|
      if t.player == player
        score += 100 / (t.degree+1)  #shouldn't have to do this, degree == 0
      else                           #should mean that the position is final
        score -= 100 / (t.degree+1)  #in which case we shouldn't be evaluating
      end
    end

    puts "score nil!" if score.nil?
    score
  end

  def eval_player_threats( position, player )
    score = 0

    threats = position.board.threats.dup

    p_fives, p_fours, p_threes, o_fives, o_fours, o_threes = 0, 0, 0, 0, 0, 0

    while t = threats.pop
      if t.degree == 1
        overlap = threats.select { |t2| t.occupied == t2.occupied }

        if t.player == player
          p_fives += 1
        else
          o_fives += 1
        end

        threats -= overlap

      elsif t.degree == 2
        overlap = threats.select { |t2| t.occupied == t2.occupied }

        if t.player == player
          p_fours += (overlap.length == 3) ? 2 : 1
        else
          o_fours += (overlap.length == 3) ? 2 : 1
        end

        threats -= overlap

      elsif t.degree == 3
        overlap = threats.select { |t2| t.occupied == t2.occupied }

        if t.player == player
          p_threes += (overlap.length == 4) ? 2 : 1
        else
          o_threes += (overlap.length == 4) ? 2 : 1
        end

        threats -= overlap

      elsif t.degree == 4
        score += (t.player == player) ? 1 : -1
      end
    end

    opp = player == :black ? :white : :black

    count = position.board.occupied[player].length -
            position.board.occupied[opp].length

    if position.turn == player
      return 9999 if count == -1 && (p_fives >= 1 || p_fours >= 1)
      return 9999 if count == 0  && (p_fives >= 1)
    elsif position.turn == opp
      return -9999 if count == 1 && (o_fives >= 1 || o_fours >= 1)
      return -9999 if count == 0 && (o_fives >= 1)
    end

    score += 100 * p_fours   if p_fours >= 3
    score +=  50 * p_fours   if p_fours == 2
    score +=  51 * p_threes  if p_threes >= 2
    score +=  10             if p_fours == 1
    score +=  11             if p_threes == 1

    score -= 100 * o_fours   if o_fours >= 3
    score -=  50 * o_fours   if o_fours == 2
    score -=  51 * o_threes  if o_threes >= 2
    score -=  10             if o_fours == 1
    score -=  11             if o_threes == 1

    score
  end

  def eval_random( position, player )
    rand( 100 ) - 50
  end

  def score_pattern( board, c, directions )
    ns = board.coords.neighbors_nil( c, directions )
    p = [ ns.first.nil? ? nil : board[ns.first],
          board[c],
          ns.last.nil? ? nil : board[ns.last] ]

    s = PATTERNS[p]
    if s.nil?
      puts "Couldn't find pattern #{[ns.first, c, ns.last]}"
    end
    s || 0
  end

  def prune( position, player, moves )
    b = position.board

    occupied = b.occupied[:black] || []
    occupied += b.occupied[:white] if b.occupied[:white]

    return ["j9"] if occupied.length == 0

    keep = []

    occupied.each do |c| 
      b.coords.neighbors( c ).each do |nc|
        keep << nc if b[nc].nil?
      end
    end

    keep.uniq!

    keep -= occupied
    keep.map! { |c| c.to_s }

    keep
  end
end

