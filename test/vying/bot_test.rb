# frozen_string_literal: true

require_relative '../test_helper'

class TestBot < Minitest::Test
  include Vying

  def test_defaults
    assert(Bot.new.bot?)
    assert(Bot.new.ready?)
    assert(RandomBot.new.bot?)
    assert(RandomBot.new.ready?)
  end

  def test_plays
    assert(RandomBot.plays?(TicTacToe))
    assert(RandomBot.new.plays?(TicTacToe))
  end

  def test_play
    assert(Bot.play(TicTacToe).include?(RandomBot))
    assert(Bot.play(Footsteps).include?(RandomBot))
  end

  def test_name
    assert_equal('RandomBot', RandomBot.new.name)
  end

  def test_inspect
    assert(RandomBot.new.inspect)
  end

  def test_find
    assert_equal(RandomBot, Bot.find('RandomBot'))
    assert_equal(RandomBot, Bot.find('randombot'))
    assert_equal(RandomBot, Bot.find(:randombot))

    assert_nil(Bot.find('NonexistantBot'))
  end

  def test_default_for_not_implemented
    sequence, position, player = [], TicTacToe.new, :x
    assert(!RandomBot.new.resign?(sequence, position, player))
    assert(!RandomBot.new.offer_draw?(sequence, position, player))
    assert(!RandomBot.new.accept_draw?(sequence, position, player))
    assert(!RandomBot.new.request_undo?(sequence, position, player))
    assert(!RandomBot.new.accept_undo?(sequence, position, player))
  end

  def test_random_bot_select
    srand 1234

    bot = RandomBot.new
    p = TicTacToe.new

    move = bot.select([], p, :x)

    srand 1234

    assert_equal(p.moves[rand(p.moves.length)], move)
  end
end
