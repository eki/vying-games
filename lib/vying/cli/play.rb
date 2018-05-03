# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'optparse'
require 'vying'
Bot.require_all

begin
  require 'curses'
  Vying::CursesAvailable = true
rescue LoadError
  # No curses!  That's okay, we'll disable the option later...
  Vying::CursesAvailable = false
end

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

    def self.show_position_curses(game)
      position = game.history.last

      w = $scr.maxx
      h = $scr.maxy

      $scr.clear

      $scr.setpos(0, 0)
      $scr.addstr(position.to_s)

      i = position.has_moves.length - 1
      position.has_moves.each do |p|
        $scr.setpos(h - 2 - i, 0)
        i -= 1
        $scr.addstr("#{p}'s moves: #{position.moves(p).inspect}")
      end
      $scr.refresh
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

    def self.get_human_move_curses(game, player)
      position = game.history.last

      w = $scr.maxx
      h = $scr.maxy

      $scr.setpos(h - 1, 0)
      $scr.addstr('Select: ')
      $scr.refresh
      move = $scr.getstr
      exit if move == ''
      until position.move?(move)
        $scr.setpos(h - 1, 0)
        $scr.addstr('Select: ')
        $scr.refresh
        move = $scr.getstr
        exit if move == ''
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
    curses = false

    opts = OptionParser.new

    opts.banner = 'Usage: vying play [options]'
    opts.on('-r', '--rules RULES') { |r| rules = Rules.find(r) }
    opts.on('-n', '--number NUMBER') { |num| number = Integer(num) }
    opts.on('-c', '--curses') { curses = true }
    opts.on('-s', '--seed NUMBER') { |s| seed = s.to_i }

    opts.on('-p', '--player PLAYER=BOT') do |s|
      s =~ /(\w*)=([\w:]*)/
      b = Bot.find(Regexp.last_match(2))
      p2b[Regexp.last_match(1).downcase.intern] = (b ? b.new : Human.new(Regexp.last_match(2)))
    end

    opts.on('-o', '--option OPTION=VALUE') do |s|
      if s =~ /(\w+)=(.+)/
        options[Regexp.last_match(1).to_sym] = Regexp.last_match(2)
      end
    end

    opts.parse(ARGV)

    if curses
      if Vying::CursesAvailable
        $scr = Curses.init_screen
        Curses.cbreak
      else
        puts "WARNING: curses unavailable... pretending you didn't ask for it."
        curses = false
      end
    end

    games = []
    number.times do |n|
      g = Game.new(rules, seed, options)
      p2b.each { |p, b| g[p].user = b }

      until g.final?
        if g[g.turn].user.class == Human
          if curses
            CLI::Play.show_position_curses(g)
            CLI::Play.get_human_move_curses(g, g.turn)
          else
            CLI::Play.show_position(g)
            CLI::Play.get_human_move(g, g.turn)
          end
        end

        g.step
      end

      games << g

      puts "completed game #{n}"
    end

    Curses.close_screen if curses

    CLI::Play.summarize(games)
  end
end
