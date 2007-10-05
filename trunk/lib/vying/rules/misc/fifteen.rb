require 'vying/rules'

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

  attr_reader :unused, :a_list, :b_list

  players [:a, :b]

  def initialize( seed=nil )
    super

    @unused, @a_list, @b_list = (1..9).to_a, [], []
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )
    return [] if final?
    unused.map { |n| "#{turn}#{n}" }
  end

  def apply!( move )
    move.to_s =~ /(a|b)(\d)/
    n = $2.to_i
    unused.delete( n )
    a_list << n if turn == :a
    b_list << n if turn == :b
    turn( :rotate )
    self
  end

  def has_15?( list )
    list.each_subset do |subset|
      if subset.length == 3
        return true if subset.inject(0) { |n, value| n + value } == 15
      end
    end
    false
  end

  def final?
    return true  if unused.length == 0
    return false if unused.length >  4
    has_15?( a_list ) || has_15?( b_list )
  end

  def winner?( player )
    return has_15?( a_list ) if player == :a
    return has_15?( b_list ) if player == :b
  end

  def loser?( player )
    return !draw? && !has_15?( a_list ) if player == :a
    return !draw? && !has_15?( b_list ) if player == :b
  end

  def draw?
    unused.empty? && !has_15?( a_list ) && !has_15?( b_list )
  end
end

