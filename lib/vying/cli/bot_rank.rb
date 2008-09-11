# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'optparse'
require 'vying'

module CLI

  module BotRank
    def BotRank.summarize( games )
      players = {}
      games.each do |g|
        g.players.each do |p|
          players[g[p].to_s] ||= [0,0,0]
          players[g[p].to_s][0] += 1 if g.winner?( p )
          players[g[p].to_s][1] += 1 if g.loser?( p )
          players[g[p].to_s][2] += 1 if g.draw?
        end
      end
      puts
      players.each_pair { |k,v| puts "#{k} #{v[0]}-#{v[1]}-#{v[2]}" }
    end

    def BotRank.matchups( rules, bots, sofar=[], &block )
      if sofar.length == rules.players.length
        block.call( sofar ) if sofar.uniq.length > 1
        return
      end

      bots.each do |b|
        matchups( rules, bots, sofar.dup << b, &block )
      end
    end
  end

  def CLI.bot_rank

    rules = Othello
    number = 10
    bots = []

    opts = OptionParser.new
    opts.banner = "Usage: vying bot_rank [options]"
    opts.on( "-r", "--rules RULES" ) { |r| rules = Rules.find( r ) }
    opts.on( "-n", "--number NUMBER" ) { |num| number = Integer( num ) }
    opts.on( "-b", "--bots BOTS" ) { |b| bots << Bot.find( b ) }

    opts.parse( ARGV )

    bots = nil if bots.empty?
    games = []

    BotRank.matchups( rules, bots || Bot.list( rules ) ) do |m|
      number.times do |n|
        g = Game.new( rules )
        h = Hash[*rules.players.zip(m.map { |bc| bc.new } ).flatten]
        h.each { |p,u| g[p] = u }
        g.play
        games << g
    
        puts "completed game #{n} between #{m.join( ' and ' )}"
      end
      BotRank.summarize( games )
    end

    BotRank.summarize( games )
  end
end

