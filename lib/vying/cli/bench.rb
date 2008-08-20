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
    benchmark_game = false
    benchmark_marshal = false
    clear_cache = false

    opts = OptionParser.new
    opts.banner = "Usage: vying bench [options]"
    opts.on( "-r", "--rules RULES"   ) { |r| rules << Rules.find( r ) }
    opts.on( "-e", "--exclude RULES" ) { |r| exclude << Rules.find( r ) }
    opts.on( "-n", "--number NUMBER" ) { |num| n = Integer( num ) }
    opts.on( "-g", "--game" )          { benchmark_game = true }
    opts.on( "-m", "--marshal" )       { benchmark_marshal = true }
    opts.on( "-p", "--profile"       ) { require 'profile' }
    opts.on( "-c", "--clear-cache"   ) { clear_cache = true }

    opts.parse( ARGV )

    rules = Rules.latest_versions if rules.empty?
    exclude.each { |r| rules.delete( r ) }

    Benchmark.bm( 30 ) do |x|
      rules.each do |r|
        pos = r.new
        move = pos.moves.first
        p_a = Array.new( n ) { |i| pos.dup }

        x.report( "#{r} position dup" ) do
          n.times { pos.dup }
        end

        g, i = Game.new( r ), 0
        until g.final? || i == 30
          g << g.moves.first
          i += 1
        end
        marshal_p = g.history.last
        marshal_g = g
        marshal_s = Marshal.dump( marshal_p )
        marshal_gs = Marshal.dump( marshal_g )

        x.report( "#{r} marshal dump" ) do
          n.times { Marshal.dump( marshal_p ) }
        end

        x.report( "#{r} marshal load" ) do
          n.times { Marshal.load( marshal_s ) }
        end

        if benchmark_game
          x.report( "#{r} (game) marshal dump" ) do
            n.times { Marshal.dump( marshal_g ) }
          end

          x.report( "#{r} (game) marshal load" ) do
            n.times { Marshal.load( marshal_gs ) }
          end
        end

        x.report( "#{r} init" ) do
          n.times { r.new }
        end

        p_a[0] = [r.new, r.new.moves.first]
        (p_a.length - 1).times do |i|
          p = p_a[i].first.apply( p_a[i].last )
          if p.final?
            p_a[i+1] = [r.new, r.new.moves.first]
          else
            p_a[i+1] = [p, p.moves.first]
          end
        end

        p_a.each { |p,m| p.clear_cache } if clear_cache

        x.report( "#{r} move?" ) do
          p_a.each { |p,m| p.move?( m ) }
        end

        p_a.each { |p,m| p.clear_cache } if clear_cache

        x.report( "#{r} moves" ) do
          p_a.each { |p,m| p.moves }
        end

        p_a.each { |p,m| p.clear_cache } if clear_cache

        x.report( "#{r} apply" ) do
          p_a.each { |p,m| p.apply( m ) }
        end

        p_a.each { |p,m| p.clear_cache } if clear_cache

        x.report( "#{r} final?" ) do
          p_a.each { |p,m| p.final? }
        end

        x.report( "#{r} random play" ) do
          p = r.new
          n.times do
            p = r.new if p.final?
            p.apply!( p.moves[rand( p.moves.length )] )
          end
        end
      end
    end

    if benchmark_marshal
      rules.each do |r|

        g, i = Game.new( r ), 0
        until g.final? || i == 30
          g << g.moves.first
          i += 1
        end
        marshal_p = g.history.last
        marshal_g = g
        marshal_s = Marshal.dump( marshal_p )
        marshal_gs = Marshal.dump( marshal_g )

        puts "#{r} marshal dump size: #{marshal_s.length}"
      end
    end

  end
end

