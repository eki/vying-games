# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module TrickTaking

  def trump
    @trump ||= rules.trump.map { |c| Card[c] }
  end

  def suits
    unless @suits
      @suits = {}
      rules.suits.each { |s, cs| @suits[s] = cs.map { |c| Card[c] } }
    end

    @suits
  end

  def deck
    @deck ||= rules.deck.map { |c| Card[c] }
  end

  def wait_until_broken
    @wait_until_broken ||= rules.wait_until_broken.map { |c| Card[c] }
  end

  def pass_before_deal?
    rules.respond_to?(:pass_before_deal)
  end

  def pass_before_deal
    if pass_before_deal?
      @pass_before_deal ||= rules.pass_before_deal.dup
    end
  end

  def rotate_pass_before_deal
    if pass_before_deal?
      pass_before_deal[:directions] <<
        pass_before_deal[:directions].delete_at(0)
    end
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
      []
    elsif post_deal && pass?
      can_pass = []
      selected.each do |k, v|
        can_pass << k if v.length < pass_before_deal[:number]
      end

      can_pass
    else
      [turn]
    end
  end

  def moves(player)
    return [] unless player.nil? || has_moves.include?(player)
    return [] if final?

    if post_deal && pass?
      passable = {}
      hands.each do |k, v|
        passable[k] = v - selected[k] if has_moves.include?(k)
      end

      a = player ? passable[player] : passable.values.flatten
      return a.map(&:to_s)
    end

    hand = hands[turn]

    if trick.empty?
      rules.lead.each do |rule|
        if rule.kind_of?(Card)
          return [rule.to_s] if hand.include?(rule)
        elsif rule == :any
          return hand.map(&:to_s) if broken

          diff = hand - wait_until_broken
          return (diff.empty? ? hand : diff).map(&:to_s)
        end
      end
    else
      led = trick.first[1].suit

      rules.follow.each do |rule|
        case rule
          when :must_follow_suit
            on_suit = hand.select { |c| c.suit == led }
            return on_suit.map(&:to_s) unless on_suit.empty?
          when :must_trump
            in_trump = hand & rules.trump
            return in_trump.map(&:to_s) unless in_trump.empty?
        end
      end
    end

    hand.map(&:to_s)
  end

  def apply!(move, _player)
    move = Card[move]

    if post_deal && pass?
      hands.each { |k, v| selected[k] << move if v.include?(move) }
      if selected.all? { |k, v| v.length == pass_before_deal[:number] }
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

        hands.each { |k, v| hands[k] -= selected[k] }

        @post_deal = false
        rotate_pass_before_deal
        @selected = { n: [], e: [], w: [], s: [] }
        rotate_turn until hands[turn].include?(Card[:C2])
        hands.each { |k, v| v.sort! }
      end

      rotate_turn until has_moves.include?(turn)

      return self
    end

    hand = hands[turn]
    card = Card[move]

    trick << [turn, hand.delete(card)]

    @broken = true if wait_until_broken.include?(card)

    if trick.size == players.size

      capture_by = trick.first[0]
      capture_card = trick.first[1]

      led = capture_card.suit
      capture_index = suits[led].index(capture_card)

      trumped = false

      trick.each do |p, c|
        if c.suit == led
          i = suits[led].index(c)
          if i < capture_index
            capture_index = i
            capture_card = c
            capture_by = p
          end
        elsif trump.include?(c)
          i = trump.index(c)
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
      rotate_turn until turn == capture_by

      if hands[turn].empty?
        score_hand

        @tricks = {}

        return self if final?

        d = Deck.new(deck, rng).shuffle.deal(players.size, rules.deal_out)
        d.zip(players) { |h, p| hands[p] = h }
        hands.each { |k, v| v.sort! }

        @post_deal = true

        if no_pass?
          rotate_pass_before_deal
          @post_deal = false
          rotate_turn until hands[turn].include?(Card[:C2])
        end
      end
    else
      rotate_turn
    end

    rotate_turn until has_moves.include?(turn)

    self
  end

end
