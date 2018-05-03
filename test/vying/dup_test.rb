
require_relative '../test_helper'

class TestDup < Minitest::Test
  def test_deep_dup_self
    assert_equal( :a1.object_id,   :a1.deep_dup.object_id )
    assert_equal( 1.object_id,     1.deep_dup.object_id )
    assert_equal( nil.object_id,   nil.deep_dup.object_id )
    assert_equal( true.object_id,  true.deep_dup.object_id )
    assert_equal( false.object_id, false.deep_dup.object_id )
  end

  def test_deep_dup_string
    s = "blah"
    d = s.deep_dup

    assert( s.object_id != d.object_id )
    assert_equal( s, d )

    s.upcase!

    assert( s != d )
  end

  def test_deep_dup_array
    a = [1, :yo, "dog", nil, [1, 2, 3, "..."], true, false]
    d = a.deep_dup

    assert_equal( a, d )

    assert( a[0].object_id == d[0].object_id )
    assert( a[1].object_id == d[1].object_id )
    assert( a[2].object_id != d[2].object_id )
    assert( a[3].object_id == d[3].object_id )
    assert( a[4].object_id != d[4].object_id )
    assert( a[5].object_id == d[5].object_id )
    assert( a[6].object_id == d[6].object_id )

    assert( a[4][0].object_id == d[4][0].object_id )
    assert( a[4][1].object_id == d[4][1].object_id )
    assert( a[4][2].object_id == d[4][2].object_id )
    assert( a[4][3].object_id != d[4][3].object_id )

    a[0] = 3
    assert( a != d )

    d[0] = 3
    assert( a == d )

    a[2].upcase!
    assert( a != d )

    d[2].upcase!
    assert( a == d )
  end

  def test_deep_dup_hash
    h = { 1   => [:a, 3, "cat"], 
          :yo => { :a => false, 
                   :b => "dude", 
                   :c => true, 
                   :d => nil } 
        }

    d = h.deep_dup

    assert_equal( h, d )

    assert( h[1].object_id   != d[1].object_id )
    assert( h[:yo].object_id != d[:yo].object_id )

    assert( h[1][0].object_id == d[1][0].object_id )
    assert( h[1][1].object_id == d[1][1].object_id )
    assert( h[1][2].object_id != d[1][2].object_id )

    assert( h[:yo][:a].object_id == d[:yo][:a].object_id ) 
    assert( h[:yo][:b].object_id != d[:yo][:b].object_id ) 
    assert( h[:yo][:c].object_id == d[:yo][:c].object_id ) 
    assert( h[:yo][:d].object_id == d[:yo][:d].object_id )

    h[:yo][:a] = 42
    assert( h != d )

    d[:yo][:a] = 42
    assert( h == d )

    h[:yo][:b].upcase!
    assert( h != d )

    d[:yo][:b].upcase!
    assert( h == d )
  end

end

