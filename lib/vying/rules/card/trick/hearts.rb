# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create('Hearts') do
  name    'Hearts'
  version '0.5.0'

  players [:n, :e, :s, :w]

  lowest_score_determines_winner

  random

  deck [:SA, :SK, :SQ, :SJ, :ST, :S9, :S8, :S7, :S6, :S5, :S4, :S3, :S2,
        :CA, :CK, :CQ, :CJ, :CT, :C9, :C8, :C7, :C6, :C5, :C4, :C3, :C2,
        :HA, :HK, :HQ, :HJ, :HT, :H9, :H8, :H7, :H6, :H5, :H4, :H3, :H2,
        :DA, :DK, :DQ, :DJ, :DT, :D9, :D8, :D7, :D6, :D5, :D4, :D3, :D2]

  suits spades: [:SA, :SK, :SQ, :SJ, :ST, :S9, :S8, :S7, :S6, :S5, :S4, :S3, :S2],
        clubs: [:CA, :CK, :CQ, :CJ, :CT, :C9, :C8, :C7, :C6, :C5, :C4, :C3, :C2],
        hearts: [:HA, :HK, :HQ, :HJ, :HT, :H9, :H8, :H7, :H6, :H5, :H4, :H3, :H2],
        diamonds: [:DA, :DK, :DQ, :DJ, :DT, :D9, :D8, :D7, :D6, :D5, :D4, :D3, :D2]

  trump             []
  lead              [Card[:C2], :any]
  follow            [:must_follow_suit]
  deal_out          13
  wait_until_broken [:HA, :HK, :HQ, :HJ, :HT, :H9, :H8, :H7, :H6, :H5, :H4, :H3, :H2]

  pass_before_deal  number: 3,
                    directions: [:left, :right, :across, :no_pass]

  position do
    include TrickTaking

    attr_reader :hands, :tricks, :trick, :broken, :post_deal, :selected

    def init
      @hands = {}
      d = Deck.new(deck, rng).shuffle.deal(players.size, rules.deal_out)
      d.zip(players) { |h, p| hands[p] = h }
      hands.each { |k, v| v.sort! }
      @post_deal = true

      @tricks = {}
      @selected = { n: [], s: [], e: [], w: [] }
      @trick = []
      @broken = false
      @score = Hash.new(0)

      # This code should effectively never be run... (and thus removed),
      # because every game of Hearts starts with passing, and we don't want
      # to rotate turn because it would reveal to the players who has C2

      unless post_deal && pass?
        rotate_turn until hands[turn].include?(Card[:C2])
      end
    end

    def censor(player)
      pos = super
      pos.hands.each do |k, v|
        pos.hands[k] = [:hidden] * pos.hands[k].length if k != player
      end
      pos.selected.each do |k, v|
        pos.selected[k] = [:hidden] * pos.selected[k].length if k != player
      end
      pos
    end

    def score_hand
      tmp_scores = { n: 0, e: 0, w: 0, s: 0 }

      tricks.each do |p, ts|
        cards = ts.map { |t| t.map { |p2, c| c } }.flatten!
        tmp_scores[p] += cards.inject(0) do |s, c|
          v = 0
          v = 1  if c.suit == :hearts
          v = 13 if c == Card[:SQ]
          s + v
        end
      end

      if !(shot_moon = tmp_scores.select { |k, v| v == 26 }).empty?
        # Note (1.8): shot_moon looks something like this [[:e,26]], for example
        # Note (1.9): shot_moon looks something like this {:e=>26}, for example

        # TODO: Do we reset the player who shot the moon's tmp_score back to 0?

        if shot_moon.class == Array
          tmp_scores.each { |k, v| @score[k] += 26 if k != shot_moon[0][0] }
        elsif shot_moon.class == Hash
          tmp_scores.each { |k, v| @score[k] += 26 if k != shot_moon.keys.first }
        end
      else
        tmp_scores.each { |k, v| @score[k] += v }
      end
    end

    def final?
      !@score.select { |k, v| v >= 100 }.empty?
    end

    def score(player)
      @score[player]
    end
  end
end
