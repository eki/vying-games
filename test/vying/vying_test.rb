
require 'test/unit'
require 'vying'

class TestVying < Test::Unit::TestCase
  def test_version
    assert( Vying.version )
  end
end

