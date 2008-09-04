# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

begin
  require 'random'

  module Vying
    RANDOM_SUPPORT = true
  end

  # RandomNumberGenerator is a thin wrapper around Random::MersenneTwister.  It
  # provides a simpler interface to Rules that have random elements.  It also
  # has a few small benefits over Random::MersenneTwister.  For one, it provides
  # faster, lazier (deep) dup'ing, marshaling, and yaml-izing.  It also provides
  # a quick equality check.

  class RandomNumberGenerator
    attr_reader :seed, :count

    # Provide the seed to initialize the RandomNumberGenerator with.  If no
    # seed is given one will be taken from Kernel.rand (given a max of 2**30-1).

    def initialize( seed=nil )
      @seed = seed || Kernel.rand( 2**30-1 )
      @count = 0
      @rng = Random::MersenneTwister.new( seed )
    end

    # Same as Kernel.rand, but uses MersenneTwister.
  
    def rand( n=nil )
      if @rng.nil?
        @rng = Random::MersenneTwister.new( seed )
        count.times { @rng.rand }
      end

      @count += 1
      @rng.rand( n )
    end

    # Makes a deep, lazy copy of this RandomNumberGenerator.  The MersenneTwiser
    # that's used behind the scenes is *not* recreated until the first call
    # to #rand.

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

    # Only the seed and count are dumped when marshalling.

    def _dump( depth=-1 )
      Marshal.dump( [seed, count] )
    end

    # Load mashalled data.

    def self._load( s )
      s, c = Marshal.load( s )
      rng = self.allocate
      rng.instance_variable_set( "@seed", s )
      rng.instance_variable_set( "@count", c )
      rng
    end

    # Only the seed and count are written out to YAML.

    def to_yaml_properties
      ["@seed","@count"]
    end
  end

rescue LoadError

  module Vying
    RANDOM_SUPPORT = false
  end

  # RandomNumberGenerator is a thin wrapper around Random::MersenneTwister.  It
  # provides a simpler interface to Rules that have random elements.  It also
  # has a few small benefits over Random::MersenneTwister.  For one, it provides
  # faster, lazier (deep) dup'ing, marshaling, and yaml-izing.  It also provides
  # a quick equality check.

  class RandomNumberGenerator
    attr_reader :seed, :count

    # Provide the seed to initialize the RandomNumberGenerator with.  If no
    # seed is given one will be taken from Kernel.rand (given a max of 2**30-1).

    def initialize( seed=nil )
      raise "'random' gem missing.  Random games are not supported"
    end

    # Same as Kernel.rand, but uses MersenneTwister.
  
    def rand( n=nil )
      raise "'random' gem missing.  Random games are not supported"
    end

    # Makes a deep, lazy copy of this RandomNumberGenerator.  The MersenneTwiser
    # that's used behind the scenes is *not* recreated until the first call
    # to #rand.

    def dup
      raise "'random' gem missing.  Random games are not supported"
    end

    # Compare this rng against another.

    def eql?( o )
      raise "'random' gem missing.  Random games are not supported"
    end

    # Compare this rng against another.

    def ==( o )
      raise "'random' gem missing.  Random games are not supported"
    end

    # Only the seed and count are dumped when marshalling.

    def _dump( depth=-1 )
      raise "'random' gem missing.  Random games are not supported"
    end

    # Load mashalled data.

    def self._load( s )
      raise "'random' gem missing.  Random games are not supported"
    end

    # Only the seed and count are written out to YAML.

    def to_yaml_properties
      raise "'random' gem missing.  Random games are not supported"
    end
  end

end

