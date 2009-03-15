# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# This is an implementation of American Checkers, or Straight Checkers, or
# British Draughts, or, etc, etc, depending on what part of the world you're
# from.
#
# For more detailed rules, etc:  http://vying.org/games/american_checkers

Rules.create( "AmericanCheckers" ) do
  name    "American Checkers"
  version "1.0.0"
  notation :checkers_notation

  players :red, :white

  king :red   => :RED_KING,
       :white => :WHITE_KING

  pieces :red   => [:red, :RED_KING],
         :white => [:white, :WHITE_KING]

  step_directions :red        => [:se, :sw], 
                  :white      => [:ne, :nw],
                  :RED_KING   => [:se, :sw, :ne, :nw],
                  :WHITE_KING => [:se, :sw, :ne, :nw]

  jump_directions :red        => [:se, :sw], 
                  :white      => [:ne, :nw],
                  :RED_KING   => [:se, :sw, :ne, :nw],
                  :WHITE_KING => [:se, :sw, :ne, :nw]

  can_capture :red        => [:white, :WHITE_KING], 
              :white      => [:red, :RED_KING],
              :RED_KING   => [:white, :WHITE_KING],
              :WHITE_KING => [:red, :RED_KING]


  allow_draws_by_agreement

  cache :init, :moves, :final?

  position do
    attr_reader :board, :jumping

    def init
      @board = Board.square( 8 )
      @board[:b1,:d1,:f1,:h1,:a2,:c2,:e2,:g2,:b3,:d3,:f3,:h3] = :red
      @board[:a8,:c8,:e8,:g8,:b7,:d7,:f7,:h7,:a6,:c6,:e6,:g6] = :white

      @jumping = false
    end

    def has_moves
      return [turn] if jumping

      rules.pieces[turn].each do |p|
        board.occupied( p ).each do |c|
          return [turn] if can_step?( c ) || can_jump?( c )
        end
      end

      []
    end

    def moves
      return jump_moves( jumping ) if jumping

      ms = all_jump_moves( turn )
      return ms unless ms.empty?

      all_step_moves( turn )
    end

    def apply!( move )
      coords, p = Coord.expand( move.to_coords ), turn

      board.move( coords.first, coords.last )

      if coords.length == 3
        board[coords[1]] = nil

        if can_jump?( coords.last )
          @jumping = coords.last
        else
          rotate_turn
          @jumping = false
        end
      else
        rotate_turn
      end

      if p == :red && coords.last.y == 7
        board[coords.last] = rules.king[:red]
      elsif p == :white && coords.last.y == 0
        board[coords.last] = rules.king[:white]
      end

      self
    end

    def final?
      has_moves.empty?
    end

    def winner?( player )
      player != turn
    end

    def score( player )
      opp = opponent( player )
      oppk = rules.king[opp]
      12 - board.count( opp ) - board.count( oppk )
    end

    private

    def can_step?( c )
      rules.step_directions[board[c]].any? do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        c1 && ! p1
      end
    end

    def can_jump?( c )
      p = board[c]
      rules.step_directions[p].any? do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        p2 = board[c2 = board.coords.next( c1, d )] if c1
        c2 && ! p2 && rules.can_capture[p].include?( p1 )
      end
    end

    def step_moves( c )
      ms = []
      rules.step_directions[board[c]].each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        ms << "#{c}#{c1}" if c1 && ! p1
      end
      ms
    end

    def jump_moves( c )
      p = board[c]
      ms = []
      rules.step_directions[board[c]].each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        p2 = board[c2 = board.coords.next( c1, d )] if c1
        ms << "#{c}#{c2}" if c2 && ! p2 && rules.can_capture[p].include?( p1 )
      end
      ms
    end

    def all_step_moves( player )
      rules.pieces[player].map do |p|
        board.occupied( p ).map { |c| step_moves( c ) }
      end.flatten
    end

    def all_jump_moves( player )
      rules.pieces[player].map do |p|
        board.occupied( p ).map { |c| jump_moves( c ) }
      end.flatten
    end

  end

end

