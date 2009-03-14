
require 'test/unit'
require 'vying'

class TestOpeningBook < Test::Unit::TestCase
  include Vying

  def test_initialize
    book = OpeningBook.new

    assert_equal( 1, book.lines.length )
    assert( book.line( "" ) )
    assert_equal( [], book.moves( "" ) )
  end

  def test_add_01
    book = OpeningBook.new

    sequences = [ [:a1, :b2, :a2, :c3] ]

    sequences.each do |s|
      g = Game.new( TicTacToe )
      g << s
      book.add( g )
    end

    assert_equal( 4, book.lines.length )

    assert_equal( ["a1"], book.moves( "" ) )

    assert( book.line( ["a1"] ) )
    assert( book.line( ["a1", "b2"] ) )
    assert( book.line( ["a1", "b2", "a2"] ) )

    assert( book.line( "a1" ) )
    assert( book.line( "a1,b2" ) )
    assert( book.line( "a1,b2,a2" ) )

    assert( book.lines.all? { |line| line.frequency == 1 } )

    assert( ["b2"], book.moves( "a1" ) )
    assert( ["a2"], book.moves( "a1,b2" ) )
    assert( [], book.moves( "a1,b2,a2" ) )
  end

  def test_add_02
    book = OpeningBook.new

    sequences = [ [:a1, :b2, :a2, :c3],
                  [:a1, :b2, :b3, :c3] ]

    sequences.each do |s|
      g = Game.new( TicTacToe )
      g << s
      book.add( g )
    end

    assert_equal( 5, book.lines.length )

    assert_equal( ["a1"], book.moves( "" ) )

    assert( book.line( ["a1"] ) )
    assert( book.line( ["a1", "b2"] ) )
    assert( book.line( ["a1", "b2", "a2"] ) )
    assert( book.line( ["a1", "b2", "b3"] ) )

    assert( book.line( "a1" ) )
    assert( book.line( "a1,b2" ) )
    assert( book.line( "a1,b2,a2" ) )
    assert( book.line( "a1,b2,b3" ) )

    assert( book.lines.all? { |line| line.frequency >= 1 } )

    assert( 1, book.line( "a1,b2,a2" ).frequency )
    assert( 1, book.line( "a1,b2,b3" ).frequency )

    assert( 2, book.line( "a1,b2" ).frequency )
    assert( 2, book.line( "a1" ).frequency )

    assert( ["b2"], book.moves( "a1" ) )
    assert( ["a2", "b3"], book.moves( "a1,b2" ) )
    assert( [], book.moves( "a1,b2,a2" ) )
  end

  def test_add_03
    book = OpeningBook.new

    sequences = [ [:a1, :b2, :a2, :c3],
                  [:a1, :b2, :b3, :c3],
                  [:a1, :a2, :b2, :b3],
                  [:b2, :a1, :b3, :c3],
                  [:b2, :b1, :b3, :c3],
                  [:b2, :c1, :b3, :c3],
                  [:b2, :c1, :b3, :c3],
                  [:b2, :c1, :b3, :c3],
                  [:b2, :c1, :b3, :c3],
                  [:b2, :c2, :b3, :c3] ]

    sequences.each do |s|
      g = Game.new( TicTacToe )
      g << s
      book.add( g )
    end

    assert_equal( 16, book.lines.length )

    assert_equal( ["a1", "b2"], book.moves( "" ) )

    assert( book.line( ["b2", "c1"] ) )
    assert( book.line( "b2,c1" ) )

    assert( ["b3"], book.moves( "b2,c1" ) )
  end

  def test_trim
    book = OpeningBook.new

    sequences = [ [:a1, :b2, :a2, :c3],
                  [:a1, :b2, :b3, :c3],
                  [:a1, :a2, :b2, :b3],
                  [:b2, :a1, :b3, :c3],
                  [:b2, :b1, :b3, :c3],
                  [:b2, :c1, :b3, :c3],
                  [:b2, :c1, :b3, :c3],
                  [:b2, :c1, :b3, :c3],
                  [:b2, :c1, :b3, :c3],
                  [:b2, :c2, :b3, :c3] ]

    sequences.each do |s|
      g = Game.new( TicTacToe )
      g << s
      book.add( g )
    end

    assert_equal( 16, book.lines.length )

    book.trim( 2 )

    assert_equal( 5, book.lines.length )

    assert( book.line( "a1" ) )
    assert( book.line( "a1,b2" ) )
    assert( book.line( "b2" ) )
    assert( book.line( "b2,c1" ) )
    assert( book.line( "b2,c1,b3" ) )
  end

end

