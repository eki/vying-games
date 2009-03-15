# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Vying.rules( "Pig" ) do
  name    "Pig"
  version "1.0.0"

  players :a, :b

  highest_score_determines_winner

  random

  position do
    attr_reader :total, :current_score, :roll_history

    def init
      @total, @current_score = Hash.new( 0 ), 0
      @roll_history = { :a => [], :b => [] }
    end

    def moves
      final? ? [] : %w(pass roll)
    end

    def apply!( move )
      move = move.to_s

      if move == 'pass'
        total[turn] += current_score
        @current_score = 0
        rotate_turn

      elsif move == 'roll'
        @roll_history[turn] << [] if @current_score == 0

        r = [1, 2, 3, 4, 5, 6][rand( 6 )]

        @roll_history[turn].last << r

        if r == 1
          @current_score = 0
          rotate_turn
        else
          @current_score += r
        end
      end

      self
    end

    def final?
      total.select { |k,v| v >= 100 }.size > 0
    end

    def score( player )
      total[player] 
    end
  end

end

