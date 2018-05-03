
require_relative '../test_helper'

class TestUser < Minitest::Test
  include Vying

  def test_defaults
    assert( ! User.new.bot? )
    assert( ! User.new.ready? )

    assert_raises( RuntimeError ) do
      User.new.select( TicTacToe.new, [], :x )
    end

    sequence, position, player = [], TicTacToe.new, :x
    assert( ! User.new.resign?( sequence, position, player ) )
    assert( ! User.new.offer_draw?( sequence, position, player ) )
    assert( ! User.new.accept_draw?( sequence, position, player ) )
    assert( ! User.new.request_undo?( sequence, position, player ) )
    assert( ! User.new.accept_undo?( sequence, position, player ) )
  end

  def test_hash
    assert_equal( User.new( "dude" ).hash, User.new( "dude" ).hash )
    assert_equal( User.new( "dude", 3 ).hash, User.new( "dude" ).hash )
  end

  def test_eql?
    assert_equal( User.new( "dude" ), Human.new( "dude" ) )
    assert_equal( User.new( "RandomBot" ), RandomBot.new )
    refute_equal( nil, User.new( "dude" ) )
    refute_equal( User.new( "dude" ), nil )
    refute_equal( User.new( "dude" ), User.new( "dudette" ) )
  end

  def test_human
    u = Human.new

    assert( ! u.ready? )    
    assert( ! u.accept_draw?( nil, nil, nil ) )

    u << "accept_draw"

    assert( u.ready? )    
    assert( u.accept_draw?( nil, nil, nil ) )
    assert( ! u.ready? )    
    assert( ! u.accept_draw?( nil, nil, nil ) )

    u << "blah"

    assert( u.ready? )    
    assert( ! u.accept_draw?( nil, nil, nil ) )
    assert( u.ready? )    
    assert_equal( "blah", u.select( nil, nil, nil ) )
    assert( ! u.ready? )    

    u << "reject_draw"

    assert( u.ready? )    
    assert( ! u.accept_draw?( nil, nil, nil ) )
    assert( ! u.ready? )    

    u << "offer_draw"

    assert( u.ready? )    
    assert( u.offer_draw?( nil, nil, nil ) )
    assert( ! u.ready? )    
    assert( ! u.offer_draw?( nil, nil, nil ) )

    u << "request_undo"

    assert( u.ready? )    
    assert( u.request_undo?( nil, nil, nil ) )
    assert( ! u.ready? )    
    assert( ! u.request_undo?( nil, nil, nil ) )

    u << "accept_undo"

    assert( u.ready? )    
    assert( u.accept_undo?( nil, nil, nil ) )
    assert( ! u.ready? )    
    assert( ! u.accept_undo?( nil, nil, nil ) )

    u << "reject_undo"

    assert( u.ready? )    
    assert( ! u.accept_undo?( nil, nil, nil ) )
    assert( ! u.ready? )    

    u << "resign"

    assert( u.ready? )    
    assert( u.resign?( nil, nil, nil ) )
    assert( ! u.ready? )    
    assert( ! u.resign?( nil, nil, nil ) )
  end

end

