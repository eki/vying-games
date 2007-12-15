# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

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

    def pass_before_deal( a )
      info[:pass_before_deal] = a
      alias_method :old_pass_before_deal, :pass_before_deal
      def pass_before_deal; info[:pass_before_deal]; end
    end
  end

  include Meta

  def self.append_features(klass)
    super
    klass.extend( Meta )
  end

  #position :dealer, :hands, :tricks, :trick

  def pass_before_deal?
    info.key? :pass_before_deal
  end

  def no_pass?
    pass_before_deal? && pass_before_deal[:directions].first == :no_pass
  end

  def pass?
    pass_before_deal? && pass_before_deal[:directions].first != :no_pass
  end

  def pass_left?
    pass_before_deal? && pass_before_deal[:directions].first == :left
  end

  def pass_right?
    pass_before_deal? && pass_before_deal[:directions].first == :right
  end

  def pass_across?
    pass_before_deal? && pass_before_deal[:directions].first == :across
  end

  def has_moves
    if final?
      return []
    elsif post_deal && pass?
      can_pass = []
      selected.each do |k,v|
        can_pass << k if v.length < pass_before_deal[:number]
      end

      return can_pass
    else
      return [turn]
    end
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )
    return [] if final?

    if post_deal && pass?
      passable = {}
      hands.each do |k,v|
        passable[k] = v - selected[k] if has_moves.include?( k )
      end

      a = player ? passable[player] : passable.values.flatten
      return a.map { |c| c.to_s }
    end

    hand = hands[turn]

    if trick.empty?
      lead.each do |rule|
        if rule.kind_of?( Card )
          return [rule.to_s] if hand.include?( rule )
        elsif rule == :any
          return (broken ? hand : hand - wait_until_broken).map { |c| c.to_s }
        end
      end
    else
      led = trick.first[1].suit

      follow.each do |rule|
        case rule
          when :must_follow_suit
            on_suit = hand.select { |c| c.suit == led }
            return on_suit.map { |c| c.to_s } unless on_suit.empty?
          when :must_trump
            in_trump = hand & trump
            return in_trump.map { |c| c.to_s } unless in_trump.empty?
        end
      end
    end

    hand.map { |c| c.to_s }
  end

  def apply!( move )
    move = Card[move]

    if post_deal && pass?
      hands.each { |k,v| selected[k] << move if v.include?( move ) }
      if selected.all? { |k,v| v.length == pass_before_deal[:number] }
        if pass_left?
          hands[:n] += selected[:w]
          hands[:w] += selected[:s]
          hands[:s] += selected[:e]
          hands[:e] += selected[:n]
        elsif pass_right?
          hands[:n] += selected[:e]
          hands[:w] += selected[:n]
          hands[:s] += selected[:w]
          hands[:e] += selected[:s]
        elsif pass_across?
          hands[:n] += selected[:s]
          hands[:w] += selected[:e]
          hands[:s] += selected[:n]
          hands[:e] += selected[:w]
        end

        hands.each { |k,v| hands[k] -= selected[k] }

        @post_deal = false
        pass_before_deal[:directions] << 
          pass_before_deal[:directions].delete_at( 0 )
        @selected = { :n => [], :e => [], :w => [], :s => [] }
        turn( :rotate ) until hands[turn].include?( Card[:C2] )
        hands.each { |k,v| v.sort! }
      end

      turn( :rotate ) until has_moves.include?( turn )

      return self
    end

    hand = hands[turn]
    card = Card[move]

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

        @post_deal = true

        if no_pass?
          pass_before_deal[:directions] << 
            pass_before_deal[:directions].delete_at( 0 )
          @post_deal = false
          turn( :rotate ) until hands[turn].include?( Card[:C2] )
        end
      end
    else
      turn( :rotate )
    end

    turn( :rotate ) until has_moves.include?( turn )

    self
  end

end

