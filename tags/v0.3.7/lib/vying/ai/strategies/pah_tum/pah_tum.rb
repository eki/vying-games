# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

module PahTumStrategies

  def eval_score( position, player )
    opp = player == :black ? :white : :black

    position.score( player ) - position.score( opp )
  end

  def eval_neighbors( position, player )
    b, score, ds = position.board, 0, [:n, :e, :w, :s]
    b.occupied[player].each do |c|
      score += 1 if b[*b.coords.neighbors( c, ds )].any? { |p| p == player }
    end
    score
  end

  def eval_defense( position, player )
    opp = player == :black ? :white : :black
    b, score, ds = position.board, 0, [:n, :e, :w, :s]
    b.occupied[opp].each do |c|
      rc     = b[*b.coords.row( c )] + b[*b.coords.column( c )]
      score += 1 * rc.select { |p| p == player || p == :x }.length
    end
    score
  end

  def eval_potential( position, player )
    b, score, ds = position.board, 0, [:n, :e, :w, :s]
    b.occupied[player].each do |c|
      space = b[*b.coords.row( c )] + b[*b.coords.column( c )]
      ns    = b[*b.coords.neighbors( c, ds )]
      score += 1 * space.select { |p| p == player || p.nil? }.length
      score += 3 * ns.select { |p| p == player || p.nil? }.length
    end
    score
  end

end

