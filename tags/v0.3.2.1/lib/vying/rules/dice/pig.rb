require 'vying/rules'

class Pig < Rules

  info :name => 'Pig',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Pig_(dice)>']

  attr_reader :total, :score, :rolling

  players [:a, :b]

  random

  def initialize( seed=nil )
    super

    @total, @score, @rolling = Hash.new( 0 ), 0, false
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
        total[turn] += score
        @score = 0
        turn( :rotate )
      when 'roll'
        @rolling = true
      when '1'
        @score = 0
        turn( :rotate )
        @rolling = false
      else
        @score += move.to_i
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
end

