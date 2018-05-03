# frozen_string_literal: true

# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying
  class Move::Withdraw < SpecialMove

    def self.[](s)
      new(Regexp.last_match(1)) if s =~ /(\w+)_withdraws$/
    end

    def initialize(by)
      @move, @by = "#{by}_withdraws", by.to_sym
    end

    def valid_for?(game, player=nil)
      game.unrated? &&
      (player.nil? || player == by) && (game.player?(by) && game[by].user)
    end

    def self.generate_for(game, player=nil)
      ms = []
      game.player_names.each do |p|
        m = new(p)
        ms << m if m.valid_for?(game, player)
      end
      ms
    end

    def before_apply(game)
      game.withdraw(by)
    end

  end
end
