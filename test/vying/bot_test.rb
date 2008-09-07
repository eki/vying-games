
require 'test/unit'
require 'vying'

class FirstMoveBot < Bot
  class TicTacToe < Bot
    difficulty :easy
    def select( sequence, position, player )
      position.moves.first
    end
  end

  class Connect6 < Bot
    difficulty :medium
    def select( sequence, position, player )
      position.moves.first
    end
  end
end

module NamespaceForTesting
  class LastMoveBot < Bot
    class TicTacToe < Bot
      difficulty :easy
      def select( sequence, position, player )
        position.moves.first
      end
    end
  end
end

class TestBot < Test::Unit::TestCase
  def test_defaults
    assert( Bot.new.bot? )
    assert( Bot.new.ready? )
    assert( RandomBot.new.bot? )
    assert( RandomBot.new.ready? )
  end

  def test_delegate_for
    bot = RandomBot.new

    assert_equal( RandomBot::TicTacToe.new, bot.delegate_for( TicTacToe.new ) )
    assert_equal( RandomBot::Footsteps.new, bot.delegate_for( Footsteps.new ) )

    bot = FirstMoveBot.new

    assert_equal( FirstMoveBot::TicTacToe.new, 
      bot.delegate_for( TicTacToe.new ) )
    assert_equal( nil, bot.delegate_for( Footsteps.new ) )
  end

  def test_plays
    assert( RandomBot.plays?( TicTacToe ) )
    assert( RandomBot.new.plays?( TicTacToe ) )

    assert( FirstMoveBot.plays?( TicTacToe ) )
    assert( FirstMoveBot.new.plays?( TicTacToe ) )

    assert( ! FirstMoveBot.plays?( Footsteps ) )
    assert( ! FirstMoveBot.new.plays?( Footsteps ) )

    assert( NamespaceForTesting::LastMoveBot.plays?( TicTacToe ) )
    assert( NamespaceForTesting::LastMoveBot.new.plays?( TicTacToe ) )
  end

  def test_play
    assert( Bot.play( TicTacToe ).include?( RandomBot ) )
    assert( Bot.play( Footsteps ).include?( RandomBot ) )

    assert( Bot.play( TicTacToe ).include?( FirstMoveBot ) )
    assert( ! Bot.play( Footsteps ).include?( FirstMoveBot ) )

    assert( Bot.play( TicTacToe ).include?( NamespaceForTesting::LastMoveBot))
    assert( !Bot.play( Footsteps ).include?( NamespaceForTesting::LastMoveBot))
  end

  def test_name
    assert_equal( "RandomBot", RandomBot.new.name )
    assert_equal( "FirstMoveBot", FirstMoveBot.new.name )
  end

  def test_inspect
    assert( RandomBot.new.inspect )
  end

  def test_difficulty_unknown
    assert_equal( :unknown, RandomBot.difficulty_for( TicTacToe ) )
    assert_equal( :unknown, RandomBot.new.difficulty_for( TicTacToe ) )
  end

  def test_difficulty
    assert_equal( :easy, FirstMoveBot.difficulty_for( TicTacToe ) )
    assert_equal( :medium, FirstMoveBot.new.difficulty_for( Connect6 ) )
  end

  def test_find
    assert_equal( RandomBot, Bot.find( "RandomBot" ) )
    assert_equal( RandomBot, Bot.find( "randombot" ) )
    assert_equal( RandomBot, Bot.find( :randombot ) )

    assert_equal( RandomBot, Bot.find( "RandomBot::TicTacToe" ) )

    assert_equal( FirstMoveBot, Bot.find( "FirstMoveBot::TicTacToe" ) )
    assert_equal( nil, Bot.find( "FirstMoveBot::Footsteps" ) )
    assert_equal( nil, Bot.find( "FirstMoveBot::Xyzzy" ) )

    assert_equal( nil, Bot.find( "NonexistantBot" ) )

    assert_equal( NamespaceForTesting::LastMoveBot, 
                  Bot.find( "NamespaceForTesting::LastMoveBot" ) )

    assert_equal( NamespaceForTesting::LastMoveBot, 
                  Bot.find( "NamespaceForTesting::LastMoveBot::TicTacToe" ) )
  end

  def test_default_for_not_implemented
    sequence, position, player = [], TicTacToe.new, :x
    assert( ! RandomBot.new.resign?( sequence, position, player ) )
    assert( ! RandomBot.new.offer_draw?( sequence, position, player ) )
    assert( ! RandomBot.new.accept_draw?( sequence, position, player ) )
    assert( ! RandomBot.new.request_undo?( sequence, position, player ) )
    assert( ! RandomBot.new.accept_undo?( sequence, position, player ) )
  end

  def test_random_bot_select
    srand 1234

    bot = RandomBot.new
    p = TicTacToe.new

    move = bot.select( [], p, :x )

    srand 1234

    assert_equal( p.moves[rand( p.moves.length )], move )
  end
end

