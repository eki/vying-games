# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Footsteps" ) do
  name    "Footsteps"
  version "2.5.0"

  players :left, :right

  direction :left => -1, :right => 1
  winner    :left =>  0, :right => 6

  position do
    attr_reader :points, :bids, :rounds, :marker

    def init
      @marker = 3

      @points = { :left => 50,  :right => 50  }
      @bids   = { :left => nil, :right => nil }
      @rounds = []
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

      players.each { |p| bids[p] ||= 0  if points[p] == 0 }

      if players.all? { |p| bids[p] }
        if bids[:left] == bids[:right]
          winner = nil
        else
          winner = bids[:left] > bids[:right] ? :left : :right
        end

        round = { :points => points.dup,
                  :bids   => bids.dup,
                  :winner => winner,
                  :marker => { :from => @marker } }

        @marker += rules.direction[winner]  if winner

        round[:marker][:to] = @marker

        rounds << round

        players.each do |p| 
          points[p] -= bids[p]
          bids[p] = nil 
        end
      end

      self
    end

    def final?
      marker == 0 || marker == 6 || points.values.all? { |p| p == 0 }
    end

    def winner?( player )
      rules.winner[player] == marker
    end

    def draw?
      ! players.any? { |p| winner?( p ) }
    end

    def censor( player )
      position = super( player )

      players.each do |p| 
        position.bids[p] = :hidden if p != player && ! position.bids[p].nil? 
      end

      position
    end

    def sealed_moves( player )
      sealed = []

      players.each do |p|
        sealed << bids[p]  if p != player && ! bids[p].nil?
      end

      sealed
    end
  end

end

