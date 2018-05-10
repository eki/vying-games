# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'optparse'
require 'vying'
Vying::Bot.require_all

module CLI

  module Play
    def self.summarize(games)
      players = {}
      games.each do |g|
        g.players.each do |p|
          players[p] ||= [0, 0, 0]
          players[p][0] += 1 if g.winner?(p)
          players[p][1] += 1 if g.loser?(p)
          players[p][2] += 1 if g.draw?
        end
      end
      players.each_pair { |k, v| puts "#{k} #{v[0]}-#{v[1]}-#{v[2]}" }
    end

    def self.show_position(game)
      position = game.history.last

      puts position
      position.has_moves.each do |p|
        puts "#{p}'s moves: #{position.moves(p).inspect}"
      end
    end

    def self.get_human_move(game, player)
      position = game.history.last

      print 'Select: '

      move = $stdin.gets.chomp

      if move == ''
        puts 'exiting...'
        exit
      end

      until position.move?(move, player)
        puts "'#{move}' not a valid move for #{player}!"

        print 'Select: '

        move = $stdin.gets.chomp

        if move == ''
          puts 'exiting...'
          exit
        end
      end
      game[player] << move
    end
  end

  def self.play
    rules = Othello
    seed = nil
    options = {} # These are rules specific options, not cli options.

    p2b = {}
    number = 1

    opts = OptionParser.new

    opts.banner = 'Usage: vying play [options]'
    opts.on('-r', '--rules RULES') { |r| rules = Rules.find(r) }
    opts.on('-n', '--number NUMBER') { |num| number = Integer(num) }
    opts.on('-s', '--seed NUMBER') { |s| seed = s.to_i }

    opts.on('-p', '--player PLAYER=BOT') do |s|
      s =~ /(\w*)=([\w:]*)/
      b = Vying::Bot.find(Regexp.last_match(2))
      p2b[Regexp.last_match(1).downcase.intern] = (b ? b.new : Vying::Human.new(Regexp.last_match(2)))
    end

    opts.on('-o', '--option OPTION=VALUE') do |s|
      if s =~ /(\w+)=(.+)/
        options[Regexp.last_match(1).to_sym] = Regexp.last_match(2)
      end
    end

    opts.parse(ARGV)

    games = []
    number.times do |n|
      g = Game.new(rules, seed, options)
      p2b.each { |p, b| g[p].user = b }

      until g.final?
        if g[g.turn].user.class == Vying::Human
          CLI::Play.show_position(g)
          CLI::Play.get_human_move(g, g.turn)
        end

        g.step
      end

      games << g

      puts "completed game #{n}"
    end

    CLI::Play.summarize(games)
  end
end
