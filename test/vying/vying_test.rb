
require_relative '../test_helper'

class TestVying < Minitest::Test
  def test_version
    assert( Vying.version )
  end
end

