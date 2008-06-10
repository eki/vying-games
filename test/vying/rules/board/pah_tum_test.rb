require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

if Vying::RandomSupport

  class TestPahTum < Test::Unit::TestCase
    include RulesTests

    def rules
      PahTum
    end

    def test_info
      assert_equal( "Pah-Tum", rules.name )
    end

    def test_players
      assert_equal( [:white,:black], rules.new.players )
    end

    def test_initialize
      g = Game.new( rules, 1234 )
      assert_equal( :white, g.turn )
      assert_equal( 11, g.board.occupied[:x].length )
      assert_equal( nil, g.board.occupied[:white] )
      assert_equal( nil, g.board.occupied[:black] )
    end

    def test_has_moves
      g = Game.new( rules, 1234 )
      assert_equal( [:white], g.has_moves )
      g << g.moves.first
      assert_equal( [:black], g.has_moves )
      g << g.moves.first
      assert_equal( [:white], g.has_moves )
    end

    def test_line_score
      p = rules.new( 1234 )
      assert_equal(   0, p.line_score( 0 ) )
      assert_equal(   0, p.line_score( 1 ) )
      assert_equal(   0, p.line_score( 2 ) )
      assert_equal(   3, p.line_score( 3 ) )
      assert_equal(  10, p.line_score( 4 ) )
      assert_equal(  25, p.line_score( 5 ) )
      assert_equal(  56, p.line_score( 6 ) )
      assert_equal( 119, p.line_score( 7 ) )
    end

    def test_pieces_score
      p = rules.new( 1234 )

      w = { [:white, :white, :white, :white, :white, :white, :white] => 119,
            [:white, :white, :black, :white, :white, nil,    :black] =>   0,
            [nil,    :white, :white, :white, nil,    :white, nil   ] =>   3,
            [:white, :white, :white, :black, :white, :white, :white] =>   6,
            [:black, :white, :white, :white, :white, :black, :black] =>  10,
            [:black, :black, :black, :white, :white, :white, :white] =>  10,
            [nil,    nil,    nil,    :white, :white, :white, :white] =>  10,
            [:black, :white, :white, :white, :white, :white, :black] =>  25,
            [:white, :white, :white, :white, :white, :white, nil   ] =>  56,
            [:black, :white, :white, :white, :white, :white, :white] =>  56 }

      opp = { :white => :black, :black => :white, nil => nil }

      w.each do |pieces, score|
        assert_equal( score, p.pieces_score( :white, pieces ) )

        b_pieces = pieces.map { |piece| opp[piece] }
        assert_equal( score, p.pieces_score( :black, b_pieces ) ) 
      end
    end

    def test_score
      p = rules.new( 1234 )

      p.board[:a1, :a2, :a3, :a4] = :black
      p.board[:a5, :a6, :a7] = :white

      assert_equal( 10, p.score( :black ) )
      assert_equal(  3, p.score( :white ) )

      p.board[:b2,:c2,:e2] = :black
      p.board[:d2,:d3,:d4] = :white

      assert_equal( 13, p.score( :black ) )
      assert_equal(  6, p.score( :white ) )

      p.board.coords.each do |c|
        p.board[c] = :x if p.board[c].nil?
      end

      p.unused_moves.clear

      assert( p.final? )
      assert( p.winner?( :black ) )
      assert( p.loser?( :white ) )
      assert( !p.draw? )
    end

  end

end

