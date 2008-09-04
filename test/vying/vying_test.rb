
require 'test/unit'
require 'vying'

class TestVying < Test::Unit::TestCase
  def test_version
    assert( Vying.version )
  end

  def test_random_support
    assert( Vying.respond_to?( :random_support? ) )
  end

end

