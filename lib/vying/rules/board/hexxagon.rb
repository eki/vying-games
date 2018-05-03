# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Hexxagon is Ataxx played on a hex board.  Unlike, Ataxx which uses a
# predefined lookup table of block configurations, Hexxagon uses an algorithm
# to randomly place between 0..13 blocks in a fair arrangement.  The
# arrangments differ for 2 or 3 player Hexxagon.  For rotationally equivalent
# arrangements, no effort is made to prefer one over another.
#
# For detailed rules, etc:  http://vying.org/games/hexxagon

Rules.create('Hexxagon') do
  name    'Hexxagon'
  version '1.1.0'

  players :red, :blue, :white
  option :number_of_players, default: 3, values: [2, 3]

  highest_score_determines_winner

  random
  deterministic

  cache :moves

  position do
    attr_reader :board, :block_pattern

    def init
      @board = Board.hexagon(5)

      if options[:number_of_players] == 2
        @board[:a1, :i5, :e9] = :red
        @board[:e1, :a5, :i9] = :blue
      else
        @board[:a5, :i5] = :red
        @board[:a1, :i9] = :blue
        @board[:e1, :e9] = :white
      end

      set_rand_blocks(options[:number_of_players])
    end

    def moves
      return [] if final?

      found = []

      board.occupied(turn).each do |c|
        # Adjacent moves
        board.coords.ring(c, 1).each do |c1|
          found << "#{c}#{c1}" if board[c1].nil?
        end

        # Jump moves
        board.coords.ring(c, 2).each do |c2|
          found << "#{c}#{c2}" if board[c2].nil?
        end
      end

      found
    end

    def apply!(move)
      coords, p = move.to_coords, turn

      if board.coords.ring(coords.first, 1).include?(coords.last)
        board[coords.last] = turn
      else
        board.move(coords.first, coords.last)
      end

      board.coords.neighbors(coords.last).each do |c|
        unless board[c].nil? || board[c] == turn || board[c] == :x
          board[c] = turn
        end
      end

      rotate_turn

      (options[:number_of_players] - 1).times do
        if moves.empty?
          rotate_turn
          clear_cache
        end
      end

      self
    end

    def final?
      return true if board.unoccupied.empty?

      np = @options[:number_of_players]
      zero_count = players.select { |p| board.count(p) == 0 }.length

      np - 1 == zero_count
    end

    def score(player)
      board.count(player)
    end

    def set_rand_blocks(np)
      n = rand_number_of_blocks(np)
      m = rules.block_maps[np]

      m.keys.sort_by(&:to_s).sort_by { rand }.each do |c|
        if n - 1 - m[c].length >= 0
          board[c] = :x
          m[c].each { |mc| board[mc] = :x }
          n -= (1 + m[c].length)
        end

        break if n == 0
      end
    end

    def rand_number_of_blocks(np)
      m = np == 2 ? 30 : 24

      r = rand(Vying::Subset.count_subsets_less_than(14, m))

      (0..14).to_a.each do |n|
        p = Vying::Subset.count_subsets(n, m)
        return n if r < p
        r -= p
      end

      raise "Couldn't determine number of random blocks!"
    end
  end

  block_maps(2 => { c7: [], d6: [], e5: [], f4: [], g3: [],
                    f2: [:h4], b6: [:d8],
                    d1: [:i6], e2: [:h5], f3: [:g4],
                    a4: [:f9], b5: [:e8], c6: [:d7],
                    c1: [:i7], d2: [:h6], e3: [:g5],
                    a3: [:g9], b4: [:f8], c5: [:e7],
                    b1: [:i8], c2: [:h7], d3: [:g6], e4: [:f5],
                    a2: [:h9], b3: [:g8], c4: [:f7], d5: [:e6],
                    b2: [:h8], c3: [:g7], d4: [:f6] },

             3 => { e5: [],
                    b2: [:h5, :e8], c3: [:g5, :e7], d4: [:f5, :e6],
                    b1: [:i6, :d8], c1: [:i7, :c7], d1: [:i8, :b6],
                    c2: [:h6, :d7], d2: [:h7, :c6],
                    e2: [:h8, :b5], f2: [:h9, :a4],
                    d3: [:g6, :d6], e3: [:g7, :c5],
                    f3: [:g8, :b4], g3: [:g9, :a3],
                    e4: [:f6, :d5], f4: [:f7, :c4],
                    g4: [:f8, :b3], h4: [:f9, :a2] })
end
