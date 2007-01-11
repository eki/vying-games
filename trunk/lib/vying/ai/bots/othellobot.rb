require 'vying/ai/bot'
require 'vying/ai/search'

class Corner
  attr_reader :corner, :x, :c, :edge, :edge_array

  def initialize( a )
    @key, @edge_array = [:empty, :black, :white], a
    @corner, @x, @c, @edge = a.map { |i| @key[i] }
  end

  def to_s
    " #{x.to_s[0..0]} \n#{corner.to_s[0..0]}#{c.to_s[0..0]}#{edge.to_s[0..0]}\n"
  end
end


class OthelloBot < Bot
  include Minimax

  attr_reader :leaf, :nodes

  def initialize
    super
    @leaf = 0
    @nodes = 0

#    $:.each do |d|
#      Dir.glob( "**/corners.yaml" ) do |fn|
#        open( fn, "r" ) { |f| @corners = YAML.load( f ) }
#      end
#    end

    @corners = nil

    fn = "/home/eki/projects/vying/trunk/lib/vying/ai/bots/corners.yaml" 
    @corners = YAML.load_file( fn )

    fn = "/home/eki/projects/vying/trunk/lib/vying/ai/bots/edge.yaml" 
    @edges = YAML.load_file( fn )
  end

  def select( position, player )
    @leaf, @nodes = 0, 0
    score, op = best( analyze( position, player ) )
    #puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
    op
  end

  def evaluate( position, player )
    @leaf += 1

    opp = position.players.select { |p| p != player }.first
    p_count = count( position, player )
    opp_count = count( position, opp )
    total = p_count + opp_count

    return (p_count - opp_count) * 1000 if position.final?

    score = 0

    if total < 30
      score = #eval_frontier( position, player ) +
              eval_board_early( position, player ) +
              eval_corners( position, player ) +
              eval_edges( position, player ) +
              (opp_count - p_count) * 12
    elsif total < 55
      score = eval_corners( position, player ) +
              eval_edges( position, player )
    else
      score = eval_corners( position, player ) +
              eval_edges( position, player ) +
              eval_full_edges( position, player ) * 20
    end
  end

  def cutoff( position, depth )
    position.final? || depth >= 1
  end

  def eval_corners( position, player )
    opp = position.players.select { |p| p != player }.first

    score = 0

    tmp = [[:a1,:b2,:a2,:a3],
           [:a1,:b2,:b1,:c1],
           [:h1,:g2,:g1,:f1],
           [:h1,:g2,:h2,:h3],
           [:a8,:b7,:b8,:c8],
           [:a8,:b7,:a7,:a6],
           [:h8,:g7,:g8,:f8],
           [:h8,:g7,:h7,:h6]].map { |c| corner( position, player, opp, *c ) }

    tmp.inject(0) { |m,c| m+@corners[c] }
  end

  def corner( position, player, opp, corner, x, c, edge )
    key = [nil, player, opp]
    [corner,x,c,edge].map do |p|
      key.index( position.board[Coord[p]] ) 
    end
  end

  def eval_edges( position, player )
    opp = position.players.select { |p| p != player }.first

    @edges[edge( position, player, opp, [:a2,:a3,:a4,:a5,:a6,:a7] )] +
    @edges[edge( position, player, opp, [:h2,:h3,:h4,:h5,:h6,:h7] )] +
    @edges[edge( position, player, opp, [:b1,:c1,:d1,:e1,:f1,:g1] )] +
    @edges[edge( position, player, opp, [:b8,:c8,:d8,:e8,:f8,:g8] )] 
  end

  def edge( position, player, opp, pieces )
    key = [nil, player, opp]
    pieces.map { |p| key.index( position.board[p] ) }
  end

  def eval_full_edges( position, player )
    b = position.board
    count_if_full( b[b.coords.row(Coord[:a1])], player ) +
    count_if_full( b[b.coords.column(Coord[:a1])], player ) +
    count_if_full( b[b.coords.row(Coord[:h8])], player ) +
    count_if_full( b[b.coords.column(Coord[:h8])], player )
  end

  def count_if_full( pieces, player )
    not_nil = pieces.select { |p| !p.nil? }
    not_nil.length == 8 ? not_nil.select { |p| p == player }.length : 0
  end

  def eval_count( position, player )
    opp = position.players.select { |p| p != player }.first
    p_count = count( position, player )
    opp_count = count( position, opp )
    total = p_count + opp_count

    if total < 30
      score = (opp_count - p_count) * 8
    elsif total < 50
      score = (opp_count - p_count) * 5
    else
      score = (p_count - opp_count) * 2   #notice flip
    end

    score
  end

  def count( position, player )
    position.board.count( player )
  end

  def eval_frontier( position, player )
    score = 0
    position.frontier.each do |c|
      if position.board[c] == player
        score -= 5
      elsif position.board[c].nil?
        score += 1
      else
        score += 6
      end
    end
    score
  end

  def eval_mobility( position, player )
    player_score = position.ops ? position.ops.length : 0
    position.turn( :rotate )
    opp_score = position.ops ? position.ops.length : 0
    player_score - opp_score
  end

  def eval_board_late( position, player )
    opp = position.players.select { |p| p != player }.first

    @comp_board ||= [[40, -5,  7,  5,  5,  7, -5, 40],
                     [-5, -8,  3,  2,  2,  3, -8, -5],
                     [ 7,  3,  4,  3,  3,  4,  3,  7],
                     [ 5,  2,  3,  4,  4,  3,  2,  5],
                     [ 5,  2,  3,  4,  4,  3,  2,  5],
                     [ 7,  3,  4,  3,  3,  4,  3,  7],
                     [-5, -8,  3,  2,  2,  3, -8, -5],
                     [40, -5,  7,  5,  5,  7, -5, 40]]

    score = 0
    8.times do |i|
      8.times do |j|
        piece = position.board[i,j]
        score += @comp_board[i][j] if piece == player
        score -= @comp_board[i][j] if piece != player && !piece.nil?
      end
    end

    score
  end

  def eval_board_early( position, player )
    opp = position.players.select { |p| p != player }.first

    @comp_board ||= [[ 0,  0,  0,  0,  0,  0,  0,  0],
                     [ 0,  0,  1,  1,  1,  1,  0,  0],
                     [ 0,  1,  2,  4,  4,  2,  1,  0],
                     [ 0,  1,  4,  5,  5,  4,  1,  0],
                     [ 0,  1,  4,  5,  5,  4,  1,  0],
                     [ 0,  1,  2,  4,  4,  2,  1,  0],
                     [ 0,  0,  1,  1,  1,  1,  0,  0],
                     [ 0,  0,  0,  0,  0,  0,  0,  0]]

    score = 0
    8.times do |i|
      8.times do |j|
        piece = position.board[i,j]
        score += @comp_board[i][j] if piece == player
        score -= @comp_board[i][j] if piece != player && !piece.nil?
      end
    end

    score
  end
end

