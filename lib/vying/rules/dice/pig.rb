# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Pig" ) do
  name    "Pig"
  version "1.0.0"

  players :a, :b

  score_determines_outcome
  random

  position do
    attr_reader :total, :current_score, :rolling

    def init
      @total, @current_score, @rolling = Hash.new( 0 ), 0, false
    end

    def moves
      return []              if final?
      return %w(1 2 3 4 5 6) if  rolling
      return %w(pass roll)   if !rolling
      []
    end

    def has_moves
      final? ? [] : [rolling ? :random : turn]
    end

    def apply!( move )
      case move 
        when 'pass'
          total[turn] += current_score
          @current_score = 0
          rotate_turn
        when 'roll'
          @rolling = true
        when '1'
          @current_score = 0
          rotate_turn
          @rolling = false
        else
          @current_score += move.to_i
          @rolling = false
      end

      self
    end

    def final?
      total.select { |k,v| v >= 100 }.size > 0
    end

    def score( player )
      total[player] 
    end

    def hash
      [total, current_score, rolling].hash
    end
  end

end

