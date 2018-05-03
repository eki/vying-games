# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/memoize'

class Card
  include Comparable

  SUITS = [:clubs, :spades, :diamonds, :hearts].freeze
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, :ten, :jack, :queen, :king, :ace].freeze

  SUIT_COLORS = { clubs: :black, spades: :black,
                  diamonds: :red, hearts: :red }.freeze

  RANK_PIPS = { 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7,
                8 => 8, 9 => 9, :ten => 10, :ace => 1 }.freeze

  FACE_RANKS = [:jack, :queen, :king].freeze

  attr_reader :suit, :rank, :color, :pips

  def initialize(s, r, c=nil, p=nil)
    @suit, @rank = s, r
    @color = c || SUIT_COLORS[s]
    @pips  = p || RANK_PIPS[r] || 0
  end

  def self.[](s)
    s.to_s =~ /(.)(.)/
    suit = SUITS.select { |s| s.to_s[0..0].upcase == Regexp.last_match(1) }
    rank = RANKS.select { |r| r.to_s[0..0].upcase == Regexp.last_match(2) }
    Card.new(suit.first, rank.first)
  end

  class << self
    extend Memoizable
    memoize :new
    memoize :[]
  end

  ALL = SUITS.map { |s| RANKS.map { |r| Card.new(s, r) } }.flatten!

  def value?
    case rank
      when :king  then 13
      when :queen then 12
      when :jack  then 11
      when :ace   then 14 # or should we make this 1?
      else pips
    end
  end

  def <=>(card)
    tc = (color.to_s <=> card.color.to_s)
    return tc if tc != 0

    ts = (suit.to_s <=> card.suit.to_s)
    return ts if ts != 0

    card.value? - value?
  end

  def eql?(card)
    self == card
  end

  def hash
    [suit, rank].hash
  end

  def to_s
    return "#{suit.to_s[0..0].upcase}#{rank}" if rank.kind_of? Integer
    "#{suit.to_s[0..0].upcase}#{rank.to_s[0..0].upcase}"
  end

  def inspect
    to_s
  end
end

class Deck
  attr_reader :cards, :rng

  def initialize(cards=Card::ALL.dup, rng=Random::MersenneTwister.new)
    @cards = cards
    @rng = rng
  end

  def shuffle
    @cards = cards.sort_by { rng.rand }
    self
  end

  def deal(hands, num=:all)
    num = cards.size / hands if num == :all
    tmp = cards.slice!(0, num * hands)
    (0...hands).map do |i|
      last, a = num * hands, []
      (i...last).step(hands) { |j| a << tmp[j] }
      a
    end
  end
end
