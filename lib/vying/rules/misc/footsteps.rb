# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Footsteps" ) do
  name    "Footsteps"
  version "2.0.0"

  players :left, :right

  winner_direction :left => :w, :right => :e

  position do
    attr_reader :board, :points, :bids, :bid_history

    def init
      @board = Board.rect( 7, 1 )
      @board[:d1] = :white

      @points = { :left => 50, :right => 50 }
      @bids = { :left => nil, :right => nil }
      @bid_history = { :left => [], :right => [] }
    end

    def has_moves
      final? ? [] : players.select { |p| ! bids[p] && points[p] > 0 }
    end

    def moves( player )
      return [] if final?

      (1..(points[player])).to_a
    end

    def apply!( move, player )
      bid = move.to_i

      bids[player] = bid

      players.each { |p| bids[p]  ||= 0 if points[p]  == 0 }

      if players.all? { |p| bids[p] }
        c = board.occupied( :white ).first

        max_bid = bids.values.max
        wps = players.select { |p| bids[p] == max_bid }

        if wps.length == 1
          d = Coords::DIRECTIONS[rules.winner_direction[wps.first]]
          board.move( c, c + d )
        end

        players.each do |p| 
          points[p] -= bids[p]
          bid_history[p] << bids[p]
          bids[p] = nil 
        end
      end

      self
    end

    def final?
      c = board.occupied( :white ).first
      c.x == 0 || c.x == 6 || 
      (points[:left] == 0 && points[:right] == 0)
    end

    def winner?( player )
      c = board.occupied( :white ).first
      (player == :left  && c.x == 0) ||
      (player == :right && c.x == 6)
    end

    def loser?( player )
      c = board.occupied( :white ).first
      (player == :left  && c.x == 6) ||
      (player == :right && c.x == 0)
    end

    def draw?
      c = board.occupied( :white ).first
      c.x != 0 && c.x != 6 && points[:left] == 0 && points[:right] == 0
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

