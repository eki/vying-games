# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

# RandomNumberGenerator is (very) partial port of the C code from the random 
# gem (version 0.2.1).  
#
# For credits, licensing, and more on the algorithm, see: 
#
#   http://random.rubyforge.org/rdoc/index.html
# 
# This rng strives to provide a compatibility with Random::MersenneTwister,
# with a greatly reduced interface.  The goal is simply to provide the #rand
# method (and a .new method that accepts a seed).
#
# For a given seed this rng provides the exact same results as
# Random::MersenneTwister.
#
# Under Ruby 1.8 this code is about 3x slower than Random::MersenneTwister, but 
# benchmarking shows comparable runtimes under Ruby 1.9.
#
# The vying library uses this rng because it's possible to save state / have
# multiple independant rng instances loaded at the same time.  This is
# important for replaying games / managing more than one game at a time.

class RandomNumberGenerator

  N, M = 624, 397

  attr_reader :seed, :count

  # Provide the seed to initialize the RandomNumberGenerator with.  If no
  # seed is given one will be taken from Kernel.rand (given a max of 2**32-1).

  def initialize( seed=nil )
    @count = 0

    @seed = seed || Kernel.rand( 2**32-1 )

    if @seed < 0 || @seed >= 2**32
      raise RangeError, "Seed must be greater than 0 and less than 2**32"
    end

    init_state
  end

  # Same behavior as Kernel#rand.  That is, given a positive integer n, it
  # will return a random number r such that r >= 0 and < n.  For given n < 1, 
  # a random float r in the range of r >= 0 and r < 1.0 is returned.
  
  def rand( n=0 )
    @count += 1

    n = n.to_i.abs

    return rand_float if n == 0

    n -= 1
    used = n

    used |= used >> 1;
    used |= used >> 2;
    used |= used >> 4;
    used |= used >> 8;
    used |= used >> 16;

    i = rand_int & used
    i = rand_int & used until i <= n
    i
  end

  # Makes a deep, lazy copy of this RandomNumberGenerator.  The rng's state
  # is not fully recreated until the next random number is requested.

  def dup
    rng = self.class.allocate
    rng.instance_variable_set( "@seed", seed )
    rng.instance_variable_set( "@count", count )
    rng
  end

  # Compare this rng against another.

  def eql?( o )
    seed == o.seed && count == o.count
  end

  # Compare this rng against another.

  def ==( o )
    eql? o
  end

  def hash
    [@seed, @count].hash
  end

  # Special inspect string that shows the seed and number of numbers that 
  # have been generated.

  def inspect
    "#<RNG seed: #{@seed}, count: #{@count}>"
  end

  # Only the seed and count are dumped when marshalling.

  def _dump( depth=-1 )
    Marshal.dump( [seed, count] )
  end

  # Load mashalled data.  This is lazy in the same way that .dup is lazy.

  def self._load( s )
    s, c = Marshal.load( s )
    rng = self.allocate
    rng.instance_variable_set( "@seed", s )
    rng.instance_variable_set( "@count", c )
    rng
  end

  # Only the seed and count are written out to YAML.  Deserializing from YAML
  # is also lazy in the same way that .dup is lazy.

  def to_yaml_properties
    ["@seed","@count"]
  end

  private

  # Copied from the hiBit macro in the random gem.

  def hi_bit( u )
    u & 0x80000000
  end

  # Copied from the loBit macro in the random gem.

  def lo_bit( u )
    u & 0x00000001
  end

  # Copied from the loBits macro in the random gem.

  def lo_bits( u )
    u & 0x7fffffff
  end

  # Copied from the mixBits macro in the random gem.

  def mix_bits( u, v )
    hi_bit(u) | lo_bits(v)
  end

  # Copied from the twist macro in the random gem.

  def twist( m, s0, s1 )
    m ^ (mix_bits( s0, s1) >> 1) ^ (-lo_bit( s1 ) & 0x9908b0df)
  end

  # Initialize the rng's state array.  (As required by creating a new RNG
  # instance or recreating one after a lazy dup or deserialization.

  def init_state
    @state, @next, @left = Array.new( N ), 0, N

    @state[0] = @seed & 0xffffffff

    i = 1
    while i < N
      @state[i] = 
        (1812433253 * 
          (@state[i-1] ^ (@state[i-1] >> 30)) % (2**32) + i) & 0xffffffff
      i += 1
    end

    reload
  end

  # Used to recreate state after a lazy dup or reserialization.  In other 
  # words, if we know the seed and the count of numbers generated, we can 
  # init_state and then pull off the given count of numbers.

  def reinit_state
    init_state
    (@count - 1).times { rand_int }
  end

  # Reload the state array with fresh numbers.  That is, we've exhausted the
  # current supply and we need some more.

  def reload
    N.times do |i|
      @state[i] = twist( 
        @state[i < N-M ? i+M : i+M-N], 
        @state[i], 
        @state[i < N-1 ? i+1 : 0] )
    end

    @left = N
    @next = 0
  end

  # Return a random integer.  This is the source of all the random numbers.
  # It will reinit_state if it is missing, and reload if it is exhausted.

  def rand_int
    reinit_state if @state.nil?

    reload if @left == 0

    @left -= 1

    s1 = @state[@next]
    @next += 1

    s1 ^= (s1 >> 11);
    s1 ^= (s1 <<  7) & 0x9d2c5680
    s1 ^= (s1 << 15) & 0xefc60000
    s1 ^ (s1 >> 18)
  end

  # Get a random float.

  def rand_float
    rand_int * (1.0/4294967296.0)
  end

end

