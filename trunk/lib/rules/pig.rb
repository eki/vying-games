require 'game'

class Pig < Rules

  info :name => 'Pig',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Pig_(dice)>']

  attr_reader :total, :score, :turn, :rolling

  players [:a, :b]

  def initialize( seed=nil )
    @total = Hash.new( 0 )
    @score = 0
    @turn = players.dup
    @rolling = false
  end

  def ops( player=nil )
    return nil           if final?
    return [1,2,3,4,5,6] if rolling && (player.nil? || player == :random)
    return [:pass,:roll] if !rolling && (player.nil? || player == turn.now)
    []
  end

  def has_ops
    [rolling ? :random : turn.now]
  end

  def apply!( op )
    case op
      when :pass
        total[turn.now] += score
        @score = 0
        turn.rotate!
      when :roll
        @rolling = true
      when 1
        @score = 0
        turn.rotate!
        @rolling = false
      else
        @score += op
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

