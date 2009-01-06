# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "NineMensMorris" ) do
  name    "Nine Men's Morris"
  version "1.0.0"

  players :black, :white

  allow_draws_by_agreement

  can_move_to :black => nil, :white => nil

  cache :init, :moves, :final?

  position do
    attr_reader :board, :remaining, :removing

    def init
      @board = Board.square( 7 )

      @board[     :b1, :c1,   :e1, :f1,
             :a2,      :c2,   :e2,      :g2,
             :a3, :b3,             :f3, :g3,
                             
             :a5, :b5,             :f5, :g5,
             :a6,      :c6,   :e6,      :g6,
                  :b7, :c7,   :e7, :f7       ] = :x

      @board[:d4] = :X

      @remaining = { :black => 9, :white => 9 }
      @removing = false
    end

    def has_moves
      if remaining[turn] > 0 || removing || board.count( turn ) == 3
        return [turn]
      end

      if remaining[opponent( turn )] == 0 && 
         players.any? { |p| board.count( p ) == 2 }
        return []
      end

      board.occupied( turn ).any? { |c| can_move?( c ) } ? [turn] : []
    end

    def moves
      if remaining.all? { |p,n| n == 0 } &&
         players.any? { |p| board.count( p ) == 2 }
         
        return []
      end

      # Removing an opponent's stone

      if removing
        ops = board.occupied( opponent( turn ) )
        ms = ops.select { |c| ! mill?( c ) }

        return ms.empty? ? ops : ms
      end

      # Placing stones

      if remaining[turn] > 0
        return board.unoccupied
      end

      # Moving stones

      if board.count( turn ) > 3
        return board.occupied( turn ).map { |c| moves_for( c ) }.flatten
      end

      # Flying

      board.occupied( turn ).map { |c| flying_moves_for( c ) }.flatten
    end

    def apply!( move )
      coords, c = move.to_coords, nil

      if removing
        board[coords.first] = nil
        @removing = false

      elsif coords.length == 1
        board[coords.first] = turn
        remaining[turn] -= 1
        c = coords.first

      elsif coords.length == 2
        board.move( * coords )
        c = coords.last
      end

      if mill?( c )
        @removing = true
      else
        rotate_turn
      end

      self
    end

    def final?
      has_moves.empty?
    end

    def winner?( player )
      board.count( opponent( player ) ) == 2 || final? && turn != player
    end

    def loser?( player )
      winner?( opponent( player ) )
    end

    def score( player )
      opp = opponent( player )
      9 - remaining[opp] - board.count( opp )
    end

    def mill?( coord )
      p = board[coord]

      rules.mills.any? do |mill|
        mill.include?( coord ) && board[*mill].all? { |p1| p1 == p }
      end
    end

    private

    def can_move?( c )
      p = rules.can_move_to[board[c]]     
      [:n, :e, :s, :w].any? do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        until p1 != :x
          p1 = board[c1 = board.coords.next( c1, d)]
        end

        ! p1 && c1
      end
    end

    def moves_for( c )
      p, ms = rules.can_move_to[board[c]], []

      [:n, :e, :s, :w].each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        until p1 != :x
          p1 = board[c1 = board.coords.next( c1, d)]
        end

        ms << "#{c}#{c1}" if ! p1 && c1
      end

      ms
    end

    def flying_moves_for( c )
      board.unoccupied.map { |c1| "#{c}#{c1}" }
    end

    public

    def instructions
      return ""  if final?

      if removing
        "Remove one of your opponent's pieces."
      elsif remaining[turn] == 1
        "Place your last piece."
      elsif remaining[turn] > 1
        "Place one of your #{remaining[turn]} pieces."
      else
        "Move one of your pieces."
      end 
    end
  end

  mills ( [[:a1,:d1,:g1], [:g1, :g4, :g7], [:g7, :d7, :a7], [:a7, :a4, :a1],
           [:b2,:d2,:f2], [:f2, :f4, :f6], [:f6, :d6, :b6], [:b6, :b4, :b2],
           [:c3,:d3,:e3], [:e3, :e4, :e5], [:e5, :d5, :c5], [:c5, :c4, :c3],
           [:d1,:d2,:d3], [:d7, :d6, :d5], [:a4, :b4, :c4], [:g4, :f4, :e4]].
           map { |a| a.map { |c| Coord[c] } } )

end

