require 'game'

class Pig < Rules

  info :name => 'Pig',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Pig_(dice)>']

  position :total, :score, :turn, :rolling

  players [:a, :b]

  def Pig.init( seed=nil )
    Position.new( Hash.new( 0 ), 0, players.dup, false )
  end

  def Pig.op?( position, op, player=nil )
    ops( position, player ).include?( op )
  end

  def Pig.ops( position, player=nil )
    return []            if final? position
    return [1,2,3,4,5,6] if position.rolling == true &&
                            (player.nil? || player == :random)
    return [:pass,:roll] if position.rolling == false &&
                            (player.nil? || player == position.turn.now)
    []
  end

  def Pig.has_ops( position )
    [position.rolling ? :random : position.turn.now]
  end

  def Pig.apply( position, op )
    pos = position.dup

    case op
      when :pass
        pos.total[pos.turn.now] += pos.score
        pos.score = 0
        pos.turn.rotate!
      when :roll
        pos.rolling = true
      when 1
        pos.score = 0
        pos.turn.rotate!
        pos.rolling = false
      else
        pos.score += op
        pos.rolling = false
    end

    pos
  end

  def Pig.final?( position )
    position.total.select { |k,v| v >= 100 }.size > 0
  end

  def Pig.winner?( position, player )
    position.total[player] >= 100
  end

  def Pig.loser?( position, player )
    position.total[player] < 100
  end

  def Pig.draw?( position )
    false
  end
end

