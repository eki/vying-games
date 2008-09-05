
require 'test/unit'
require 'vying'

class TestRules < Test::Unit::TestCase
  def test_find
    Rules.latest_versions.each do |r|
      assert_equal( r, Rules.find( r.to_snake_case ) )
      assert_equal( r, Rules.find( r.class_name ) )
      assert_equal( r, Rules.find( r.class_name.downcase ) )
    end

    assert_nil( Rules.find( "foo_bar" ) )
  end

  def test_find_by_version
    r = Rules.find( Kalah, "1.0.0" )
    assert_equal( "Kalah", r.class_name )
    assert_equal( "1.0.0", r.version )

    r = Rules.find( Kalah, "2.0.0" )
    assert_equal( "Kalah", r.class_name )
    assert_equal( "2.0.0", r.version )
  end

  def test_sealed_moves
    assert(   Footsteps.sealed_moves? )
    assert( ! TicTacToe.sealed_moves? )
  end

  def test_yaml
    assert_equal( TicTacToe, YAML.load( TicTacToe.to_yaml ) )

    rs = [Rules.find( Kalah, "1.0.0" ), Rules.find( Kalah, "2.0.0" )]

    rs.each do |r|
      r2 = YAML.load( r.to_yaml )
      assert_equal( r, r2 )
      assert_equal( r.version, r2.version )
      assert_equal( r.object_id, r2.object_id )
    end
  end
end

