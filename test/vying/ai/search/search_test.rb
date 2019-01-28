# frozen_string_literal: true

require_relative '../../../test_helper'

module Vying
  module BotTemplate

    attr_reader :leaf, :nodes, :leaf_list, :nodes_list
    attr_accessor :depth

    def initialize
      super
      @leaf = 0
      @nodes = 0
    end

    # select should also take a sequence argument, but we wouldn't have
    # used it anyway (we're only interested in search results)

    def select(position, player)
      @leaf, @nodes = 0, 0
      score, move = best(analyze(position, player))

      # This should just return move in a real Bot
      # But we're only interested search results
      [score, move]
    end

    def evaluate(position, player)
      @leaf += 1
      return 1  if position.winner? player
      return 0  if position.draw?

      -1
    end

    def cutoff(position, _depth)
      position.final? # it's very abnormal to search all the way to the bottom
    end
  end

  class MiniMaxBot < Bot
    include BotTemplate
    include Minimax
  end

  class AlphaBetaBot < Bot
    include BotTemplate
    include AlphaBeta
  end
end

class TestSearch < Minitest::Test
  include Vying

  def test_alphabeta_01
    mini = MiniMaxBot.new
    alpha = AlphaBetaBot.new
    cached_alpha = AlphaBetaBot.new
    cached_alpha.cache = Search::Cache::Memory.new

    g = Game.new(TicTacToe)
    g << :a1 << :b2 << :a2 << :b1

    position = g.history.last

    m_score, m_move = mini.select(position, position.turn)
    a_score, a_move = alpha.select(position, position.turn)
    ca_score, ca_move = cached_alpha.select(position, position.turn)

    assert_equal('a3', m_move.to_s)
    assert_equal(1, m_score)

    assert_equal(m_score, a_score)
    assert_equal(m_move, a_move)
    assert(mini.leaf >= alpha.leaf)
    assert(mini.nodes >= alpha.nodes)

    assert_equal(m_score, ca_score)
    assert_equal(m_move, ca_move)
    assert(mini.leaf >= cached_alpha.leaf)
    assert(mini.nodes >= cached_alpha.nodes)

    ca_score, ca_move = cached_alpha.select(position, position.turn)

    assert_equal(m_score, ca_score)
    assert_equal(m_move, ca_move)
    assert_equal(0, cached_alpha.leaf)
    assert_equal(0, cached_alpha.nodes)
  end

  def test_alphabeta_02
    mini = MiniMaxBot.new
    alpha = AlphaBetaBot.new

    g = Game.new(TicTacToe)
    g << :a1 << :a2 << :b2 << :c3

    position = g.history.last

    m_score, m_move = mini.select(position, position.turn)
    a_score, a_move = alpha.select(position, position.turn)

    assert(%w(b1 c1).include?(m_move.to_s)) # Both can force a win
    assert_equal(1, m_score)

    assert_equal(m_score, a_score)
    assert_equal(m_move, a_move)
    assert(mini.leaf >= alpha.leaf)
    assert(mini.nodes >= alpha.nodes)
  end

  # This test takes time...
  #
  # def test_alphabeta_03
  #   mini = MiniMaxBot.new
  #   alpha = AlphaBetaBot.new
  #
  #   position = TicTacToe.new
  #
  #   m_score, m_move = mini.select( position, position.turn )
  #   a_score, a_move = alpha.select( position, position.turn )
  #
  #   assert_equal( 0, m_score )
  #
  #   puts "mini.leaf:   #{mini.leaf}"
  #   puts "mini.nodes:  #{mini.nodes}"
  #   puts "alpha.leaf:  #{alpha.leaf}"
  #   puts "alpha.nodes: #{alpha.nodes}"
  #
  #   assert_equal( m_score, a_score )
  #   assert_equal( m_move, a_move )
  #   assert( mini.leaf >= alpha.leaf )
  #   assert( mini.nodes >= alpha.nodes )
  # end

end
