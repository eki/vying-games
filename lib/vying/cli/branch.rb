# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'optparse'
require 'vying'

module CLI

  def self.branch
    rules = []
    n = 10

    opts = OptionParser.new
    opts.banner = 'Usage: vying branch [options]'
    opts.on('-r', '--rules RULES') { |r| rules << Rules.find(r) }
    opts.on('-n', '--number NUMBER') { |num| n = Integer(num) }

    opts.parse(ARGV)

    rules = Rules.list if rules.empty?

    puts format('%20s %16s %16s', 'rules', 'branch', 'moves / game')

    rules.each do |r|
      total_spread = 0
      total_moves = 0

      n.times do
        g = Game.new(r)
        until g.final?
          moves = g.moves

          total_spread += moves.length
          total_moves += 1

          begin
            g << moves[rand(moves.length)]
          rescue e
            puts g
            puts "moves: #{g.moves}"
            puts "squence: #{g.sequence.inspect}"
            raise e
          end
        end
      end

      b = total_spread.to_f / total_moves.to_f
      mg = total_moves.to_f / n.to_f

      puts format('%20s %16.2f %16.2f', r.to_s, b, mg)
    end
  end
end
