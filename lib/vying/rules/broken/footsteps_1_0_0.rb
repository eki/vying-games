# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Footsteps" ) do
  name    "Footsteps"
  version "1.0.0"
  broken

  players :left, :right

  init_moves_left  (1..50).to_a
  init_moves_right (1..50).to_a

  position do
    attr_reader :board, :points, :bids, :unused_moves_left, :unused_moves_right,
                :bid_history

    def init
      @board = Board.new( :shape => :rect, :width => 7, :height => 1 )
      @board[:d1] = :white

      @points = { :left => 50, :right => 50 }
      @bids = { :left => nil, :right => nil }
      @bid_history = { :left => [], :right => [] }

      @unused_moves_left  = rules.init_moves_left.dup
      @unused_moves_right = rules.init_moves_right.dup
    end

    def has_moves
      final? ? [] : players.select { |p| ! bids[p] && points[p] > 0 }
    end

    def moves( player=nil )
      return [] unless player.nil? || has_moves.include?( player )
      return [] if final?

      return unused_moves_left.map  { |i| "left_#{i}" }  if player == :left
      return unused_moves_right.map { |i| "right_#{i}" } if player == :right

      ms = has_moves.map do |p|
        if p == :left
          unused_moves_left.map  { |i| "left_#{i}" }  if p == :left
        elsif p == :right
          unused_moves_right.map { |i| "right_#{i}" } if p == :right
        end
      end

      ms.flatten
    end

    def apply!( move, player=nil )
      p, bid = move.to_s.split( /_/ )
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

        unused_moves_left.reject!  { |move| move > points[:left] }
        unused_moves_right.reject! { |move| move > points[:right] }
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
  end

end

