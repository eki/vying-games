
require 'test/unit'
require 'vying'

class TestFrontier < Test::Unit::TestCase

  def test_initialize
    b = Board.square( 4, :plugins => [:frontier] )

    assert( (class << b; ancestors; end).include?( Board::Plugins::Frontier ) )
    assert_equal( [], b.frontier )
  end

  def test_set
    b = Board.square( 4, :plugins => [:frontier] )
    b[:a1] = :x
    assert_equal( ["a2", "b1", "b2"], b.frontier.map { |c| c.to_s }.sort )
  end

  def test_unset
    b = Board.square( 4, :plugins => [:frontier] )
    b[:a1,:b1] = :x
    
    assert_equal( ["a2", "b2", "c1", "c2"], 
                  b.frontier.map { |c| c.to_s }.sort )

    b[:b1] = nil

    assert_equal( ["a2", "b1", "b2"], 
                  b.frontier.map { |c| c.to_s }.sort )
  end

  def test_hexagon_directions
    b = Board.hexagon( 4, :plugins => [:frontier] )
    b[:a1] = :x

    assert_equal( ["a2", "b1", "b2"], b.frontier.map { |c| c.to_s }.sort )

    b[:b2] = :x

    assert_equal( ["a2", "b1", "b3", "c2", "c3"],
                  b.frontier.map { |c| c.to_s }.sort )

    b[:a4] = :x

    assert_equal( ["a2", "a3", "b1", "b3", "b4", "b5", "c2", "c3"],
                  b.frontier.map { |c| c.to_s }.sort )

    b[:a5] = :o  # omitted from coords due to board shape

    assert_equal( ["a2", "a3", "b1", "b3", "b4", "b5", "c2", "c3"],
                  b.frontier.map { |c| c.to_s }.sort )
  end

  def test_square_no_diagonals
    b = Board.square( 4, :directions => [:n, :e, :w, :s],
                         :plugins    => [:frontier] )
    b[:a1] = :x

    assert_equal( ["a2", "b1"], b.frontier.map { |c| c.to_s }.sort )

    b[:b2] = :x

    assert_equal( ["a2", "b1", "b3", "c2"],
                  b.frontier.map { |c| c.to_s }.sort )
  end

  def test_triangle_directions
    b = Board.square( 4, :cell_shape => :triangle, :plugins => [:frontier] )
    b[:a1] = :x

    assert_equal( ["a2", "b1"], b.frontier.map { |c| c.to_s }.sort )

    b[:b1] = :x

    assert_equal( ["a2", "c1"],
                  b.frontier.map { |c| c.to_s }.sort )

    b[:b2] = :x

    assert_equal( ["a2", "b3", "c1", "c2"],
                  b.frontier.map { |c| c.to_s }.sort )
  end

  def test_dup
    b = Board.square( 4, :plugins => [:frontier] )
    b[:a1] = :x

    assert( (class << b; ancestors; end).include?( Board::Plugins::Frontier ) )

    b2 = b.dup

    assert( (class << b2; ancestors; end).include?( Board::Plugins::Frontier ) )

    assert_equal( b, b2 )
    assert_equal( b.frontier, b2.frontier )
    assert_not_equal( b.frontier.object_id, b2.frontier.object_id )
  end

  def test_marshal
    b = Board.square( 4, :plugins => [:frontier] )
    b[:a1] = :x

    assert( (class << b; ancestors; end).include?( Board::Plugins::Frontier ) )

    b2 = Marshal.load( Marshal.dump( b ) )

    assert( (class << b2; ancestors; end).include?( Board::Plugins::Frontier ) )

    assert_equal( b, b2 )
    assert_equal( b.frontier, b2.frontier )
    assert_not_equal( b.frontier.object_id, b2.frontier.object_id )
  end

  def test_yaml
    b = Board.square( 4, :plugins => [:frontier] )
    b[:a1] = :x

    assert( (class << b; ancestors; end).include?( Board::Plugins::Frontier ) )

    b2 = YAML.load( b.to_yaml )

    assert( (class << b2; ancestors; end).include?( Board::Plugins::Frontier ) )

    assert_equal( b, b2 )
    assert_equal( b.frontier, b2.frontier )
    assert_not_equal( b.frontier.object_id, b2.frontier.object_id )
  end

end

