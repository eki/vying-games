# frozen_string_literal: true

# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying

  # This is the super class for all special moves.  Unlike normal moves,
  # special moves act on Games and / or Positions, rather than just Positions.

  class SpecialMove < Move

    def special?
      true
    end

    def inspect
      @move.to_s
    end

    def effects_history?
      self.class.const_defined?(:PositionMixin)
    end

    def apply_to_position(p)
      p = p.extend_special_mixin(self.class.const_get(:PositionMixin))
      p.apply_special_move(@move, by)
      p
    end

    def apply_to_game(g)
      before_apply(g)

      if effects_history?
        g.history.append(self)
      else
        g.history.instance_variable_set('@last_move_at', Time.now)
      end

      after_apply(g)
    end

    def before_apply(game)
    end

    def after_apply(game)
    end

    class << self

      # Require all the special moves.
      def require_all
        Dir.glob("#{Vying.root}/lib/vying/special_moves/**/*.rb") do |f|
          require f.to_s
        end
      end

      def list
        @list ||= []
      end

      # When a subclass extends SpecialMove it's added to @@special_move_list.

      def inherited(child)
        list << child
      end

      def [](s)
        @instance_cache ||= {}

        return s                   if s.kind_of?(SpecialMove)
        return @instance_cache[s]  if @instance_cache[s]

        list.each do |sm|
          m = sm[s]
          return @instance_cache[s] = m if m
        end

        nil
      end

      def generate_for(game, player=nil)
        list.map { |sm| sm.generate_for(game, player) }.flatten.compact
      end

      private :new
    end

    def _dump(depth=-1)
      to_s
    end

    def self._load(str)
      self[str]
    end

  end
end
