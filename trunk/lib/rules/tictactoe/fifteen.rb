# NAME
#   Fifteen
#
# DESCRIPTION
#   Fifteen is isomorphic to Tic Tac Toe.  Each player takes turns selecting
# numbers between 1 and 9, with no number taken first.  The winner is the
# first to have any combination of his selected numbers add up to 15.
#
# RESOURCES
#   Wikipedia <http://en.wikipedia.org/wiki/Tic-tac-toe>
#

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

  INFO = Info.new( __FILE__ )

  class State < Struct.new( :unused, :a_list, :b_list, :turn )
    def to_s
      "Unused: #{unused}\nA: #{a_list}\nB: #{b_list}\nTurn: #{turn}"
    end
  end

  def Fifteen.init
    State.new( (1..9).to_a, [], [], PlayerSet.new( *players ) )
  end

  def Fifteen.players
    [Player.a,Player.b]
  end
                                                    
  def Fifteen.ops( state )
    return nil if final?( state )

    a = []

    state.unused.each do |n|
      p = state.turn

      op = Op.new( "#{p.name} takes #{n}", "#{p.short}#{n}" ) do
        s = state.dup
        s.unused.delete( n )
        s.a_list << n if state.turn == Player.a
        s.b_list << n if state.turn == Player.b
        s.turn.next!
        s
      end
      op.freeze
      a << op
    end

    (a == []) ? nil : a
  end

  def Fifteen.has_15?( list )
    list.each_subset do |subset|
      if subset.length == 3
        return true if subset.inject(0) { |n, value| n + value } == 15
      end
    end
    false
  end

  def Fifteen.final?( state )
    return true  if state.unused.length == 0
    return false if state.unused.length >  4
    has_15?( state.a_list ) || has_15?( state.b_list )
  end

  def Fifteen.winner?( state, player )
    return has_15?( state.a_list ) if player == Player.a
    return has_15?( state.b_list ) if player == Player.b
  end

  def Fifteen.loser?( state, player )
    return !draw?( state ) && !has_15?( state.a_list ) if player == Player.a
    return !draw?( state ) && !has_15?( state.b_list ) if player == Player.b
  end

  def Fifteen.draw?( state )
    state.unused.empty? && !has_15?( state.a_list ) && !has_15?( state.b_list )
  end
end

