require 'vying/cards/card'

module TrickTaking

  module Meta
    def trump( a )
      info[:trump] = a.map { |s| Card[s] }
      alias_method :old_trump, :trump
      def trump; info[:trump]; end
    end

    def suits( h )
      h.each { |k,v| h[k] = v.map { |s| Card[s] } }
      info[:suits] = h
      alias_method :old_suits, :suits
      def suits; info[:suits]; end
    end

    def deck( a )
      a = a.map { |s| Card[s] }
      info[:deck] = a
      alias_method :old_deck, :deck  # aliasing before redefinition
      def deck; info[:deck]; end     # squashes a warning
    end

    def lead( a )
      @info[:lead] = a
      alias_method :old_lead, :lead
      def lead; info[:lead]; end
    end

    def follow( a )
      info[:follow] = a
      alias_method :old_follow, :follow
      def follow; info[:follow]; end
    end

    def deal_out( d_o )
      info[:deal_out] = d_o
      alias_method :old_deal_out, :deal_out
      def deal_out; info[:deal_out]; end
    end

    def wait_until_broken( a )
      info[:wait_until_broken] = a.map { |s| Card[s] }
      alias_method :old_wait_until_broken, :wait_until_broken
      def wait_until_broken; info[:wait_until_broken]; end
    end
  end

  include Meta

  def self.append_features(klass)
    super
    klass.extend( Meta )
  end

  #position :dealer, :hands, :tricks, :trick

  def op?( op, player=nil )
    op = Card[op] unless op.kind_of?( Card )
    (ops( player ) || []).include?( op )
  end

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

        d = Deck.new( deck, rng ).shuffle.deal( players.size, deal_out )
        d.zip( players ) { |h,p| hands[p] = h }
        hands.each { |k,v| v.sort! }

        turn( :rotate ) until hands[turn].include?( Card[:C2] )
      end
    else
      turn( :rotate )
    end

    self
  end

end

