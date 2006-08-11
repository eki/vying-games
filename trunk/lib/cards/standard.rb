require 'memoize'

class Card
  include Comparable

  SUITS = [:clubs,:spades,:diamonds,:hearts]
  RANKS = [2,3,4,5,6,7,8,9,:ten,:jack,:queen,:king,:ace]

  SUIT_COLORS = { :clubs => :black, :spades => :black,
                  :diamonds => :red, :hearts => :red }

  RANK_PIPS = { 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7,
                8 => 8, 9 => 9, :ten => 10, :ace => 1 }

  FACE_RANKS = [:jack,:queen,:king]

  attr_reader :suit, :rank, :color, :pips

  def initialize( s, r, c=nil, p=nil )
    @suit, @rank = s, r
    @color = c || SUIT_COLORS[s]
    @pips  = p ||   RANK_PIPS[r] || 0
  end

  def Card.[]( s )
    s.to_s =~ /(.)(.)/
    suit = SUITS.select { |s| s.to_s[0..0].upcase == $1 }
    rank = RANKS.select { |r| r.to_s[0..0].upcase == $2 }
    Card.new( suit.first, rank.first )
  end

  class << self
    extend Memoizable
    memoize :new
    memoize :[]
  end

  ALL = SUITS.map { |s| RANKS.map { |r| Card.new( s, r ) } }.flatten!

  def value?
    case rank
      when :king  then 13
      when :queen then 12
      when :jack  then 11
      when :ace   then 14  # or should we make this 1?
      else pips
    end
  end

  def <=>( card )
    tc = (color.to_i <=> card.color.to_i)
    return tc if tc != 0

    ts = (suit.to_i <=> card.suit.to_i)
    return ts if ts != 0

    card.value? - value?
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
  attr_reader :cards

  def initialize( cards=Card::ALL.dup )
    @cards = cards
  end

  def shuffle
    @cards = cards.sort_by { rand }
    self
  end

  def deal( hands, num=:all )
    num = cards.size / hands if num == :all
    tmp = cards.slice!(0, num*hands)
    (0...hands).map do |i|
      last, a = num*hands, []
      (i...last).step( hands ) { |j| a << tmp[j] }
      a
    end
  end
end



class TrickTakingRules < Rules

  def TrickTakingRules.trump( a )
    a = a.map { |s| Card[s] }
    class_eval( "@@info[self][:trump] = a" )
    class << self; def trump; @@info[self][:trump]; end; end
  end

  def trump
    @@info[self.class][:trump]
  end

  def TrickTakingRules.suits( h )
    h.each { |k,v| h[k] = v.map { |s| Card[s] } }
    class_eval( "@@info[self][:suits] = h" )
    class << self; def suits; @@info[self][:suits]; end; end
  end

  def suits
    @@info[self.class][:suits]
  end

  def TrickTakingRules.deck( a )
    a = a.map { |s| Card[s] }
    class_eval( "@@info[self][:deck] = a" )
    class << self; def deck; @@info[self][:deck]; end; end
  end

  def deck
    @@info[self.class][:deck]
  end

  def TrickTakingRules.lead( a )
    class_eval( "@@info[self][:lead] = a" )
    class << self; def lead; @@info[self][:lead]; end; end
  end

  def lead
    @@info[self.class][:lead]
  end

  def TrickTakingRules.follow( a )
    class_eval( "@@info[self][:follow] = a" )
    class << self; def follow; @@info[self][:follow]; end; end
  end

  def follow
    @@info[self.class][:follow]
  end

  def TrickTakingRules.deal_out( d_o )
    class_eval( "@@info[self][:deal_out] = d_o" )
    class << self; def deal_out; @@info[self][:deal_out]; end; end
  end

  def deal_out
    @@info[self.class][:deal_out]
  end

  def TrickTakingRules.wait_until_broken( a )
    a = a.map { |s| Card[s] }
    class_eval( "@@info[self][:wait_until_broken] = a" )
    class << self 
      def wait_until_broken; @@info[self][:wait_until_broken]; end
    end
  end

  def wait_until_broken
    @@info[self.class][:wait_until_broken]
  end

  #position :dealer, :hands, :tricks, :trick

  def ops( player=nil )
    return [] unless player.nil? || has_ops.include?( player )
    return nil if final?

    hand = hands[turn]

    if trick.empty?
      lead.each do |rule|
        if rule.kind_of?( Card )
          return [rule] if hand.include?( rule )
        elsif rule == :any
          return broken ? hand : hand - wait_until_broken 
        end
      end
    else
      led = trick.first[1].suit

      follow.each do |rule|
        case rule
          when :must_follow_suit
            on_suit = hand.select { |c| c.suit == led }
            return on_suit unless on_suit.empty?
          when :must_trump
            in_trump = hand & trump
            return in_trump unless in_trump.empty?
        end
      end
    end

    hand
  end

  def apply!( op )
    hand = hands[turn]
    card = Card[op]

    trick << [turn, hand.delete( card )]

    @broken = true if wait_until_broken.include?( card )

    if trick.size == players.size

      capture_by = trick.first[0]
      capture_card = trick.first[1]

      led = capture_card.suit
      capture_index = suits[led].index( capture_card )

      trumped = false

      trick.each do |p,c|
        if c.suit == led
          i = suits[led].index( c )
          if i < capture_index
            capture_index = i
            capture_card = c
            capture_by = p
          end
        elsif trump.include?( c )
          i = trump.index( c )
          if i < capture_index || !trumped
            capture_index = i
            capture_card = c
            capture_by = p
            trumped = true
          end
        end
      end

      tricks[capture_by] ||= []
      tricks[capture_by] << trick
      @trick = []
      turn( :rotate ) until turn == capture_by

      if hands[turn].empty?
        score_hand

        @tricks = {}

        d = Deck.new( deck ).shuffle.deal( players.size, deal_out )
        d.zip( players ) { |h,p| hands[p] = h }

        turn( :rotate ) until hands[turn].include?( Card[:C2] )
      end
    else
      turn( :rotate )
    end

    self
  end

end

