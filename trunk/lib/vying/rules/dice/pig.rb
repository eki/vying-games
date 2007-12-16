# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

class Pig < Rules

  name    "Pig"
  version "1.0.0"

  players [:a, :b]

  random

  attr_reader :total, :current_score, :rolling

  def initialize( seed=nil )
    super

    @total, @current_score, @rolling = Hash.new( 0 ), 0, false
  end

  def moves( player=nil )
    return []              if final?
    return %w(1 2 3 4 5 6) if  rolling && (player.nil? || player == 'random')
    return %w(pass roll)   if !rolling && (player.nil? || player == turn)
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
        turn( :rotate )
      when 'roll'
        @rolling = true
      when '1'
        @current_score = 0
        turn( :rotate )
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

  def winner?( player )
    total[player] >= 100
  end

  def loser?( player )
    total[player] < 100
  end

  def score( player )
    total[player] 
  end

  def hash
    [total, current_score, rolling].hash
  end
end

