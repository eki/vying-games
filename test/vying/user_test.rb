
require 'test/unit'
require 'vying'

class TestUser < Test::Unit::TestCase
  def test_defaults
    assert( ! User.new.bot? )
    assert( ! User.new.ready? )

    assert_raise( RuntimeError ) do
      User.new.select( TicTacToe.new, [], :x )
    end

    assert( ! User.new.resign?( TicTacToe.new, [], :x ) )
    assert( ! User.new.offer_draw?( TicTacToe.new, [], :x ) )
    assert( ! User.new.accept_draw?( TicTacToe.new, [], :x ) )
    assert( ! User.new.request_undo?( TicTacToe.new, [], :x ) )
    assert( ! User.new.accept_undo?( TicTacToe.new, [], :x ) )
  end

  def test_hash
    assert_equal( User.new( "dude" ).hash, User.new( "dude" ).hash )
    assert_equal( User.new( "dude", 3 ).hash, User.new( "dude" ).hash )
  end

  def test_eql?
    assert_equal( User.new( "dude" ), Human.new( "dude" ) )
    assert_equal( User.new( "RandomBot" ), RandomBot.new )
    assert_not_equal( nil, User.new( "dude" ) )
    assert_not_equal( User.new( "dude" ), nil )
    assert_not_equal( "dude", User.new( "dude" ) )
    assert_not_equal( User.new( "dude" ), "dude" )
    assert_not_equal( 1234, User.new( "dude" ) )
    assert_not_equal( User.new( "dude" ), 1234 )
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

