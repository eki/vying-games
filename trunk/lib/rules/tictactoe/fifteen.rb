require 'game'

# These changes to Enumerable (adding powerset and each_subset) are taken from
# comp.lang.ruby.
#   <http://groups.google.com/group/comp.lang.ruby/msg/b7e6135533b85ca6?hl=en&>

module Enumerable
  def each_subset(skip_empty = false)
    enum = respond_to?( :size ) ? self : to_a

    for n in (skip_empty ? 1 : 0) ... (1 << enum.size) do
      subset = []

      enum.each_with_index do |elem, i|
        subset << elem if n[i] == 1
      end

      yield subset
    end

    self
  end

  def powerset(skip_empty = false)
    subsets = []

    each_subset(skip_empty) { |s| subsets << s }

    return subsets
  end
end 

class Fifteen < Rules

  info :name => 'Fifteen',
       :description => 'Fifteen is isomorphic to Tic Tac Toe.  Each player' +
                       ' takes turns selecting numbers between 1 and 9,' +
                       ' with no number taken first.  The winner is the' +
                       ' first to have any combination of his selected' +
                       ' numbers add up to 15.',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Tic-tac-toe>']

  position :unused, :a_list, :b_list, :turn

  players [:a, :b]

  def Fifteen.init( seed=nil )
    Position.new( (1..9).to_a, [], [], players.dup )
  end

  def Fifteen.op?( position, op, player=nil )
    return false unless player.nil? || has_ops( position ).include?( player )
    op.to_s =~ /(a|b)(\d)/
    position.turn.now.to_s == $1 && position.unused.include?( $2.to_i )
  end

  def Fifteen.ops( position, player=nil )
    return false unless player.nil? || has_ops( position ).include?( player )
    return nil if final?( position )
    a = position.unused.map { |n| "#{position.turn.now}#{n}" }
    a == [] ? nil : a
  end

  def Fifteen.apply( position, op )
    op.to_s =~ /(a|b)(\d)/
    pos, n = position.dup, $2.to_i
    pos.unused.delete( n )
    pos.a_list << n if position.turn.now == :a
    pos.b_list << n if position.turn.now == :b
    pos.turn.rotate!
    pos
  end

  def Fifteen.has_15?( list )
    list.each_subset do |subset|
      if subset.length == 3
        return true if subset.inject(0) { |n, value| n + value } == 15
      end
    end
    false
  end

  def Fifteen.final?( position )
    return true  if position.unused.length == 0
    return false if position.unused.length >  4
    has_15?( position.a_list ) || has_15?( position.b_list )
  end

  def Fifteen.winner?( position, player )
    return has_15?( position.a_list ) if player == :a
    return has_15?( position.b_list ) if player == :b
  end

  def Fifteen.loser?( position, player )
    p = position
    return !draw?( p ) && !has_15?( p.a_list ) if player == :a
    return !draw?( p ) && !has_15?( p.b_list ) if player == :b
  end

  def Fifteen.draw?( position )
    p = position
    p.unused.empty? && !has_15?( p.a_list ) && !has_15?( p.b_list )
  end
end

