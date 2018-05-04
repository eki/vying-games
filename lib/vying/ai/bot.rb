# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying

  class Bot < User
    attr_accessor :cache, :delegates

    def initialize(username=nil, id=nil)
      username ||= name

      super(username, id)

      @cache = Search::Cache::FallThrough.new
      @delegates = {}
    end

    def bot?
      true
    end

    def ready?
      true
    end

    def self.plays?(rules)
      false
    end

    def plays?(rules)
      self.class.plays?(rules)
    end

    def select(sequence, position, player)
      return position.moves.first if position.moves.length == 1

      score, move = best(analyze(position, player))

      move
    end

    def resign?(sequence, position, player)
      false
    end

    def offer_draw?(sequence, position, player)
      false
    end

    def accept_draw?(sequence, position, player)
      false
    end

    def request_undo?(sequence, position, player)
      false
    end

    def accept_undo?(sequence, position, player)
      false
    end

    def analyze(position, player)
      h = {}
      position.moves.each do |move|
        h[move] = evaluate(position.apply(move), player)
      end
      h
    end

    def best(scores)
      scores = scores.invert
      m = scores.max
      # puts "scores: #{scores.inspect} (taking #{m.inspect})"
      m
    end

    def fuzzy_best(scores, delta)
      s = []
      scores.each { |move, score| s << [score, move] }
      m = s.max
      ties = s.select { |score, move| (score - m.first).abs <= delta }
      m = ties[rand(ties.length)]
      # puts "scores: #{s.inspect}, t: #{ties.inspect} (taking #{m.inspect})"
      m
    end

    def to_s
      username || self.class.to_s
    end

    def name
      to_s
    end

    def inspect
      "#<Bot #{name}>"
    end

    def self.require_all(path=$LOAD_PATH)
      required = []
      path.each do |d|
        Dir.glob("#{d}/**/bots/**/*.rb") do |f|
          f =~ /(.*)\/bots\/(.*\.rb)$/
          if !required.include?(Regexp.last_match(2)) && !f['_test']
            required << Regexp.last_match(2)
            require f.to_s
          end
        end
      end
    end

    @@bots_list = []
    @@bots_play = {}

    def self.inherited(child)
      a = child.to_s.split(/::/)
      if a.length > 1
        bc = a[0, a.length - 1].join('::')
        if @@bots_list.any? { |b| b.to_s == bc }
          b = Bot.find(bc)
          r = Rules.find(a.last)
          (@@bots_play[r] ||= []) << b if b && r
        else
          @@bots_list << child
        end
      else
        @@bots_list << child
      end
    end

    def self.list(rules=nil)
      return @@bots_list.select { |b| b.plays?(rules) } if rules
      @@bots_list
    end

    def self.play(rules)
      list.select { |b| b.plays?(rules) }
    end

    def self.find(name)
      Bot.list.each do |b|
        return b if name.to_s.casecmp(b.to_s).zero? ||
                    name.to_s.casecmp(b.name).zero?

        a = name.to_s.split('::')
        next unless a.length > 1
        bc = a[0, a.length - 1].join('::')
        b = Bot.find(bc)
        r = Rules.find(a.last)
        return b if b && r && b.plays?(r)
      end

      nil
    end
  end
end
