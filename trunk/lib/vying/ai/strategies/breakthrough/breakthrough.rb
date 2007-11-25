# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

module BreakthroughStrategies

  def eval_distance( position, player )
    b, score = position.board, 0

    position.players.each do |p|
      ty = 0
      pc = 0

      b.occupied[p].each do |c|
        ty += c.y
        pc += 1
      end

      ay = pc > 0 ? ty / pc : 0

      ps = p == :black ? ay : 8 - ay

      score += ps if p == player
      score -= ps if p != player
    end

    score
  end

  def eval_most_advanced( position, player )
    opp = player == :black ? :white : :black
    b = position.board

    score = 0

    position.players.each do |p|
      p_my = 0
      b.occupied[p].each do |c|
        p_my = c.y   if p == :black && c.y > p_my
        p_my = 8-c.y if p == :white && 8-c.y > p_my
      end

      score += 10 * p_my if p == player
      score -= 10 * p_my if p == opp
    end

    score
  end

  def eval_clear_path( position, player )
    b = position.board.dup
    capture = { :black => [:se, :sw], :white => [:ne, :nw] }
    home = { :black => [:a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8],
             :white => [:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1] }
    cmarker = { :black => :BLACK, :white => :WHITE }
    score = 0
  
    position.players.each do |p|
      b.occupied[p].each do |c|
        capture[p].each do |d|
          c1 = position.board.coords.next( c, d )
          b[c1] = cmarker[p] unless c1.nil? || ! b[c1].nil?
        end
      end
    end

    position.players.each do |p|
      home[p].each do |sc|
        dist = find_path?( b.dup, Coord[sc], [p, cmarker[p]] )
        score += 16 / dist if dist && p == player
        score -= 16 / dist if dist && p != player
      end
    end

    score
  end

  def find_path?( board, sc, ps )
    return nil if board[sc].nil?
    return 1 if ps.include?( board[sc] )

    board[sc] = :checked

    board.coords.neighbors( sc ).each do |c|
      next unless board[c].nil?
      dist = find_path?( board, c, ps )
      return dist + 1 unless dist.nil?
    end

    return nil
  end

  def eval_captures( position, player )
    opp = player == :black ? :white : :black
    b = position.board

    (b.occupied[player].length - b.occupied[opp].length) * 5
  end

  def eval_formations( position, player )
    score = 0
    neighbors = [:n, :s, :e, :w]

    position.players.each do |p|
      position.board.occupied[p].each do |c|
        neighbors.each do |d|
          c1 = position.board.coords.next( c, d )
          score += 1 unless c1.nil? || position.board[c1].nil?
        end
      end
    end

    score
  end

  def eval_wall( position, player )
    capture = { :black => [:se, :sw], :white => [:ne, :nw] }
    coords = { :black => [], :white => [] }
    score = 0

    position.players.each do |p|
      position.board.occupied[p].each do |c|
        capture[p].each do |d|
          c1 = position.board.coords.next( c, d )
          coords[p] << c1 unless c1.nil?
        end
      end
    end

    coords.each do |p,cs|
      y_min, y_max = 9, -1
      x_counts = [0, 0, 0, 0,  0, 0, 0, 0]
      cs.each do |c|
        y_min = c.y if c.y < y_min
        y_max = c.y if c.y > y_max
        x_counts[c.x] += 1
      end

      s = cs.length
      s += x_counts.select { |i| i > 0 }.length
      s += x_counts.select { |i| i > 1 }.length
      s += 20 if y_max - y_min < 4

      score += s if p == player
      score -= s if p != player
    end

    score
  end

end

