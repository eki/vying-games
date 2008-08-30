
require 'test/unit'
require 'vying'

class TestSpecialMoves < Test::Unit::TestCase
  def test_interface
    SpecialMove.list.each do |sm|
      assert( sm.respond_to?( :[] ) )
      assert( sm.respond_to?( :generate_for ) )

      assert( sm.instance_methods.include?( 'valid_for?' ) )

      assert( sm.method( :[] ).arity == 1 )
      assert( sm.method( :generate_for ).arity == -2 )

      assert( sm.instance_method( :valid_for? ).arity == -2 )
    end
  end

  def test_double_wrap
    assert( SpecialMove["undo"] )
    assert( SpecialMove[SpecialMove["undo"]] )
  end

end

