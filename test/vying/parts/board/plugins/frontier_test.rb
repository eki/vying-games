
require 'test/unit'
require 'vying'

class TestFrontier < Test::Unit::TestCase

  def test_initialize
    b = Board.new( :shape => :square, :length => 4, :plugins => [:frontier] )

    assert( (class << b; ancestors; end).include?( Board::Plugins::Frontier ) )
    assert_equal( [], b.frontier )
  end

  def test_set
    b = Board.new( :shape => :square, :length => 4, :plugins => [:frontier] )
    b[:a1] = :x
    assert_equal( ["a2", "b1", "b2"], b.frontier.map { |c| c.to_s }.sort )
  end

  def test_dup
    b = Board.new( :shape => :square, :length => 4, :plugins => [:frontier] )
    b[:a1] = :x

    assert( (class << b; ancestors; end).include?( Board::Plugins::Frontier ) )

    b2 = b.dup

    assert( (class << b2; ancestors; end).include?( Board::Plugins::Frontier ) )

    assert_equal( b, b2 )
    assert_equal( b.frontier, b2.frontier )
    assert_not_equal( b.frontier.object_id, b2.frontier.object_id )
  end

  def test_marshal
    b = Board.new( :shape => :square, :length => 4, :plugins => [:frontier] )
    b[:a1] = :x

    assert( (class << b; ancestors; end).include?( Board::Plugins::Frontier ) )

    b2 = Marshal.load( Marshal.dump( b ) )

    assert( (class << b2; ancestors; end).include?( Board::Plugins::Frontier ) )

    assert_equal( b, b2 )
    assert_equal( b.frontier, b2.frontier )
    assert_not_equal( b.frontier.object_id, b2.frontier.object_id )
  end

  def test_yaml
    b = Board.new( :shape => :square, :length => 4, :plugins => [:frontier] )
    b[:a1] = :x

    assert( (class << b; ancestors; end).include?( Board::Plugins::Frontier ) )

    b2 = YAML.load( b.to_yaml )

    assert( (class << b2; ancestors; end).include?( Board::Plugins::Frontier ) )

    assert_equal( b, b2 )
    assert_equal( b.frontier, b2.frontier )
    assert_not_equal( b.frontier.object_id, b2.frontier.object_id )
  end

end

