
require_relative '../test_helper'

class TestSpecialMoves < Minitest::Test
  include Vying

  def test_interface
    SpecialMove.list.each do |sm|
      assert( sm.respond_to?( :[] ) )
      assert( sm.respond_to?( :generate_for ) )

      assert( sm.instance_method_defined?( 'valid_for?' ) )

      assert( sm.method( :[] ).arity == 1 )
      assert( sm.method( :generate_for ).arity == -2 )

      assert( sm.instance_method( :valid_for? ).arity == -2 )
    end
  end

  def test_double_wrap
    assert( SpecialMove["undo"] )
    assert( SpecialMove[SpecialMove["undo"]] )
  end

  def test_marshal
    sm1 = SpecialMove["undo"]
    sm2 = Marshal.load( Marshal.dump( SpecialMove["undo"] ) )
    assert_equal( sm1.object_id, sm2.object_id )

    sm3 = SpecialMove["undo_requested_by_black"]
    sm4 = Marshal.load( Marshal.dump( SpecialMove["undo_requested_by_black"] ) )
    assert_equal( sm3.object_id, sm4.object_id )
    refute_equal( sm2.object_id, sm4.object_id )

    sm5 = SpecialMove["undo_requested_by_white"]
    sm6 = Marshal.load( Marshal.dump( SpecialMove["undo_requested_by_white"] ) )
    assert_equal( sm5.object_id, sm6.object_id )
    refute_equal( sm4.object_id, sm6.object_id )
  end

  def test_inspect
    assert_equal( "undo_requested_by_x", 
                  SpecialMove["undo_requested_by_x"].inspect )
  end

end

