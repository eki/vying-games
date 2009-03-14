
require 'test/unit'
require 'vying'

class TestUndo < Test::Unit::TestCase
  include Vying

  def sm
    Move::Undo
  end

  def test_wrap
    assert( sm["undo"] )

    assert( ! sm["undo_accepted_by_black"] )
    assert( ! sm["undo_requested_by_white"] )
    assert( ! sm["red_withdraws"] )

    assert( SpecialMove["undo"] )

    assert( sm["undo"].kind_of?( sm ) )
    assert( SpecialMove["undo"].kind_of?( sm ) )
  end

  def test_by
    assert_equal( nil, sm["undo"].by )
    assert_equal( nil, sm["undo"].by )
  end

  def test_valid_for
    g = Game.new( Connect6 )

    assert( ! sm["undo"].valid_for?( g ) )

    assert( ! sm["undo"].valid_for?( g, :black ) )
    assert( ! sm["undo"].valid_for?( g, :white ) )

    g << g.moves.first

    assert( ! sm["undo"].valid_for?( g ) )

    assert( ! sm["undo"].valid_for?( g, :black ) )
    assert( ! sm["undo"].valid_for?( g, :white ) )

    g << g.moves.first

    assert( sm["undo"].valid_for?( g ) )

    assert( ! sm["undo"].valid_for?( g, :black ) )
    assert( sm["undo"].valid_for?( g, :white ) )

    g << g.moves.first

    assert( ! sm["undo"].valid_for?( g ) )

    assert( ! sm["undo"].valid_for?( g, :black ) )
    assert( ! sm["undo"].valid_for?( g, :white ) )
  end

  def test_effects_history
    assert( ! sm["undo"].effects_history? )
  end

  def test_generate_for
    g = Game.new( Connect6 )

    assert( ! sm.generate_for( g ).include?( sm["undo"] ) )

    assert( ! sm.generate_for( g, :black ).include?( sm["undo"] ) )
    assert( ! sm.generate_for( g, :white ).include?( sm["undo"] ) )

    g << g.moves.first

    assert( ! sm.generate_for( g ).include?( sm["undo"] ) )

    assert( ! sm.generate_for( g, :black ).include?( sm["undo"] ) )
    assert( ! sm.generate_for( g, :white ).include?( sm["undo"] ) )

    g << g.moves.first

    assert( sm.generate_for( g ).include?( sm["undo"] ) )

    assert( ! sm.generate_for( g, :black ).include?( sm["undo"] ) )
    assert( sm.generate_for( g, :white ).include?( sm["undo"] ) )

    g << g.moves.first

    assert( ! sm.generate_for( g ).include?( sm["undo"] ) )

    assert( ! sm.generate_for( g, :black ).include?( sm["undo"] ) )
    assert( ! sm.generate_for( g, :white ).include?( sm["undo"] ) )
  end

end

