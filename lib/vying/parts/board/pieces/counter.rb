
# frozen_string_literal: true

# Counter is a simple piece composed of a player and count.  It's immutable
# making it safe for use with Board.  The count can only be "changed" by using
# the plus and minus operators which return new Counter instances.
#
# So, something like:
#
#   board[c] += 1
#
# Will replace the counter at board[c] with a new counter who's count is 1
# greater than the previous counter.
#
# You should use Counter[] rather than Counter.new since the former is cached.
#

class Counter

  attr_reader :player, :count

  # Create a new Counter instance.

  def initialize(player, count)
    @player, @count = player, count
  end

  # Fetch a new Counter from the cache or instantiate and cache a Counter if
  # the cache doesn't already contain the given counter.

  def self.[](*args)
    @counter_cache ||= {}

    return @counter_cache[args] if @counter_cache.key?(args)

    @counter_cache[args] = new(*args)
  end

  # Add 'n' to the count of this Counter, returning a new Counter instance.
  # The argument can be anything that responds to to_i.

  def +(other)
    Counter[@player, @count + other.to_i]
  end

  # Subtract 'n' to the count of this Counter, returning a new Counter
  # instance.  The argument can be anything that responds to to_i.

  def -(other)
    Counter[@player, @count - other.to_i]
  end

  # Returns Counter#count.  This allows counters to be added / subtracted.

  def to_i
    count
  end

  # Returns "#{count}_#{player}".

  def to_s
    "#{count}_#{player}"
  end
end
