# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'optparse'
require 'vying'

CLI::SUBCOMMANDS << "branch"

module CLI

  def CLI.branch

    rules = []
    n = 10

    opts = OptionParser.new
    opts.banner = "Usage: vying branch [options]"
    opts.on( "-r", "--rules RULES" ) { |r| rules << Kernel.const_get( r ) }
    opts.on( "-n", "--number NUMBER" ) { |num| n = Integer( num ) }

    opts.parse( ARGV )

    rules = Rules.list if rules.empty?

    puts sprintf( "%20s %16s %16s", "rules", "branch", "moves / game" )

    rules.each do |r|
      total_spread = 0
      total_moves = 0
    
      n.times do
        g = Game.new( r )
        until g.final?
          moves = g.moves

          total_spread += moves.length
          total_moves += 1

          g << moves[rand(moves.length)]
        end
      end

      b = total_spread.to_f / total_moves.to_f
      mg = total_moves.to_f / n.to_f

      puts sprintf( "%20s %16.2f %16.2f", r.to_s, b, mg )
    end

  end
end

