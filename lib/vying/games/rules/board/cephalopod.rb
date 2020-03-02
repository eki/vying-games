# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/games'

# Cephalopod is a game invented by Mark Steere.  It involves filling a 5x5
# board with dice.
#
# For detailed rules see:  http://vying.org/games/cephalopod

Rules.create('Cephalopod') do
  name    'Cephalopod'
  version '1.0.0'

  players :white, :black

  highest_score_determines_winner

  combos [1, 1]     => 2,
         [1, 2]     => 3,
         [1, 3]     => 4,
         [1, 4]     => 5,
         [1, 5]     => 6,
         [2, 2]     => 4,
         [2, 3]     => 5,
         [2, 4]     => 6,
         [3, 3]     => 6,
         [1, 1, 1]   => 3,
         [1, 1, 2]   => 4,
         [1, 1, 3]   => 5,
         [1, 1, 4]   => 6,
         [1, 2, 2]   => 5,
         [1, 2, 3]   => 6,
         [2, 2, 2]   => 6,
         [1, 1, 1, 1] => 4,
         [1, 1, 1, 2] => 5,
         [1, 1, 1, 3] => 6,
         [1, 1, 2, 2] => 6

  position do
    attr_reader :board, :dice, :removed, :removed

    def init
      @board = Board.square(5, directions: [:n, :e, :w, :s])

      @dice = { black: 0, white: 0 }

      @removed = {}
    end

    def moves
      a = []

      # Remove dice

      qs = board.occupied('?')
      unless qs.empty?
        cc = qs.first
        ns = board.coords.neighbors(cc).reject { |c| board[c].nil? }

        removed_faces = @removed.values.map(&:up).sort

        if !removed_faces.empty?
          a << cc.to_s if removed_faces.length > 1

          removed_sum = removed_faces.inject(0) { |s, d| s + d }

          ns.each do |nc|
            a << nc.to_s if board[nc].up + removed_sum <= 6
          end
        else
          o_dice = Dice.new([board[*ns]].flatten)
          rules.combos.each_key do |combo|
            if o_dice.include?(combo)
              combo.each { |f| ns.each { |c| a << c.to_s if board[c].up == f } }
            end
          end

          a.uniq!
        end

        return a
      end

      # Add a die

      board.coords.each do |c|
        next unless board[c].nil?

        a << c.to_s
      end

      a
    end

    def apply!(move)
      c = Coord[move]
      if board[c].nil?
        np = board[*board.coords.neighbors(c)]
        dice = Dice.new(np.compact)

        capturing = false

        rules.combos.each_key do |combo|
          if dice.include?(combo)
            capturing = true
          end
        end

        if capturing
          board[c] = '?'
        else
          board[c] = Die.new(1, turn)
          @dice[turn] += 1
          rotate_turn
        end

      elsif board[c] == '?'
        rv = @removed.values.inject(0) { |m, d| m + d.up }
        board[c] = Die.new(rv, turn)
        @dice[turn] += 1
        @removed.clear
        rotate_turn

      else
        p, board[c] = board[c], nil
        @removed[c] =  p
        @dice[p.color] -= 1
      end

      self
    end

    def final?
      board.empty_count == 0 && board.occupied('?').empty?
    end

    def score(player)
      dice[player]
    end
  end
end
