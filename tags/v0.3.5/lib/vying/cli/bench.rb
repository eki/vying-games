# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'optparse'
require 'benchmark'
require 'vying'

CLI::SUBCOMMANDS << "bench"

module CLI
  
  def CLI.bench

    rules = []
    exclude = []
    n = 100

    opts = OptionParser.new
    opts.banner = "Usage: vying bench [options]"
    opts.on( "-r", "--rules RULES"   ) { |r| rules << Kernel.const_get( r ) }
    opts.on( "-e", "--exclude RULES" ) { |r| exclude << Kernel.const_get( r ) }
    opts.on( "-n", "--number NUMBER" ) { |n| n = Integer( n ) }
    opts.on( "-p", "--profile"       ) { require 'profile' }

    opts.parse( ARGV )

    rules = Rules.list if rules.empty?
    exclude.each { |r| rules.delete( r ) }

    Benchmark.bm( 30 ) do |x|
      rules.each do |r|
        pos = r.new
        move = pos.moves.first
        p_a = Array.new( n ) { |i| pos.dup }

        x.report( "#{r} position dup" ) do
          n.times { pos.dup }
        end

        x.report( "#{r} init" ) do
          n.times { r.new }
        end

        x.report( "#{r} move?" ) do
          n.times { pos.move?( move ) }
        end

        x.report( "#{r} moves" ) do
          n.times { pos.moves }
        end

        x.report( "#{r} apply" ) do
          p_a.each { |p| p.apply( move ) }
        end

        x.report( "#{r} final?" ) do
          n.times { pos.final? }
        end

        x.report( "#{r} random play" ) do
          g = Game.new( r )
          n.times do
            g = Game.new( r ) if g.final?
            g << g.moves[rand(g.moves.length)]
          end
        end
      end
    end

  end
end

