
require 'test/unit'
require 'vying'

if Vying.random_support?

  class TestRandomNumberGenerator < Test::Unit::TestCase
    def test_initialize
      rng = RandomNumberGenerator.new 1234
      rng2 = RandomNumberGenerator.new 1234
      rng3 = RandomNumberGenerator.new 5678

      assert_equal( 1234, rng.seed )
      assert_equal( 1234, rng2.seed )
      assert_equal( 5678, rng3.seed )

      assert_equal( 0, rng.count )
      assert_equal( 0, rng2.count )
      assert_equal( 0, rng3.count )
    end

    def test_repeatability
      rng = RandomNumberGenerator.new 1234
      rng2 = RandomNumberGenerator.new 1234

      assert_equal( rng.rand( 2000 ), rng2.rand( 2000 ) )
      assert_equal( rng.rand( 1000 ), rng2.rand( 1000 ) )
      assert_equal( rng.rand( 1000 ), rng2.rand( 1000 ) )
      assert_equal( rng.rand( 7000 ), rng2.rand( 7000 ) )

      rng = RandomNumberGenerator.new 1234
      rng3 = RandomNumberGenerator.new 5678

      # Note, this is actually a very *bad* test because there's no guarantee
      # the first 4 numbers drawn for two different seeds *can't* be the same

      assert_not_equal( rng.rand( 2000 ), rng2.rand( 2000 ) )
      assert_not_equal( rng.rand( 1000 ), rng2.rand( 1000 ) )
      assert_not_equal( rng.rand( 1000 ), rng2.rand( 1000 ) )
      assert_not_equal( rng.rand( 7000 ), rng2.rand( 7000 ) )
    end

    def test_dup
      rng = RandomNumberGenerator.new 1234

      rng.rand

      rng2 = rng.dup

      assert_equal( rng.count, rng2.count )
      assert_equal( rng.seed, rng2.seed )
      assert_equal( rng.rand( 1000 ), rng2.rand( 1000 ) )
      assert_equal( rng2.rand( 1000 ), rng.rand( 1000 ) )
    end

    def test_marshal
      rng = RandomNumberGenerator.new 1234

      rng.rand

      rng2 = Marshal.load( Marshal.dump( rng ) )

      assert_equal( rng.count, rng2.count )
      assert_equal( rng.seed, rng2.seed )
      assert_equal( rng.rand( 1000 ), rng2.rand( 1000 ) )
      assert_equal( rng2.rand( 1000 ), rng.rand( 1000 ) )
    end

    def test_yaml
      rng = RandomNumberGenerator.new 1234

      rng.rand

      rng2 = YAML::load( rng.to_yaml )

      assert_equal( rng.count, rng2.count )
      assert_equal( rng.seed, rng2.seed )
      assert_equal( rng.rand( 1000 ), rng2.rand( 1000 ) )
      assert_equal( rng2.rand( 1000 ), rng.rand( 1000 ) )
    end

  end

end

