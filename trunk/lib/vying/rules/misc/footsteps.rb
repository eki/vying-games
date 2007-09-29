require 'vying/rules'
require 'vying/board/board'

class Footsteps < Rules

  info :name      => 'Footsteps',
       :resources => 
         ['Everything2 <http://www.everything2.com/index.pl?node=Footsteps>']

  attr_reader :board, :points, :bids, :unused_ops_left, :unused_ops_right,
              :bid_history

  players [:left, :right]

  @@init_ops_left  = (1..50).to_a
  @@init_ops_right = (1..50).to_a

  def initialize( seed=nil )
    super

    @board = Board.new( 7, 1 )
    @board[:d1] = :white

    @points = { :left => 50, :right => 50 }
    @bids = { :left => nil, :right => nil }
    @bid_history = { :left => [], :right => [] }

    @unused_ops_left  = @@init_ops_left.dup
    @unused_ops_right = @@init_ops_right.dup
  end

  def has_ops
    final? ? [] : players.select { |p| ! bids[p] && points[p] > 0 }
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    !final? && ops( player ).include?( op.to_s )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    return false if final?

    return unused_ops_left.map  { |i| "left_#{i}" }  if player == :left
    return unused_ops_right.map { |i| "right_#{i}" } if player == :right

    has_ops.map do |p|
      if p == :left
        unused_ops_left.map  { |i| "left_#{i}" }  if p == :left
      elsif p == :right
        unused_ops_right.map { |i| "right_#{i}" } if p == :right
      end
    end.flatten
  end

  def apply!( op )
    p, bid = op.to_s.split( /_/ )
    p = p.intern
    bid = bid.to_i

    bids[p] = bid

    bids[:left]  ||= 0 if points[:left]  == 0
    bids[:right] ||= 0 if points[:right] == 0

    if bids[:left] && bids[:right]
      c = board.occupied[:white].first

      if bids[:left] > bids[:right]
        board[c], board[c.x-1,c.y] = nil, :white
      elsif bids[:left] < bids[:right]
        board[c], board[c.x+1,c.y] = nil, :white
      end

      players.each do |p| 
        points[p] -= bids[p]
        bid_history[p] << bids[p]
        bids[p] = nil 
      end

      unused_ops_left.reject!  { |op| op > points[:left] }
      unused_ops_right.reject! { |op| op > points[:right] }
    end

    self
  end

  def final?
    c = board.occupied[:white].first
    c.x == 0 || c.x == 6 || 
    (points[:left] == 0 && points[:right] == 0)
  end

  def winner?( player )
    c = board.occupied[:white].first
    (player == :left  && c.x == 0) ||
    (player == :right && c.x == 6)
  end

  def loser?( player )
    c = board.occupied[:white].first
    (player == :left  && c.x == 6) ||
    (player == :right && c.x == 0)
  end

  def draw?
    c = board.occupied[:white].first
    c.x != 0 && c.x != 6 && points[:left] == 0 && points[:right] == 0
  end

  def hash
    [board,points,bids].hash
  end

  def censor( player )
    position = super( player )

    players.each do |p| 
      position.bids[p] = :hidden if p != player && ! position.bids[p].nil? 
    end

    position
  end

  def turn
    has_ops.first
  end

end

