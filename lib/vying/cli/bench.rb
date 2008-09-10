# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'optparse'
require 'benchmark'
require 'vying'

CLI::SUBCOMMANDS << "bench"

module CLI
  
  def CLI.bench
    h = { 
      :rules       => [],
      :exclude     => [],
      :n           => 100,
      :clear_cache => false
    }

    benchmark = :position

    opts = OptionParser.new
    opts.banner = "Usage: vying bench [options]"
    opts.on( "-r", "--rules RULES"   ) { |r| h[:rules]   << Rules.find( r )  }
    opts.on( "-e", "--exclude RULES" ) { |r| h[:exclude] << Rules.find( r )  }
    opts.on( "-n", "--number NUMBER" ) { |n| h[:n] = n.to_i                  }
    opts.on( "-g", "--game"          ) { benchmark = :game                   }
    opts.on( "-b", "--board"         ) { benchmark = :board                  }
    opts.on( "-p", "--profile"       ) { require 'profile'                   }
    opts.on( "-c", "--clear-cache"   ) { h[:clear_cache] = true              }

    opts.parse( ARGV )

    if benchmark == :position || benchmark == :game
      h[:rules] = Rules.latest_versions if h[:rules].empty?
      h[:exclude].each { |r| h[:rules].delete( r ) }
    end

    CLI::Bench.send( benchmark, h )
  end

  module Bench

    def self.position( h )
      n = h[:n]

      Benchmark.bm( 30 ) do |x|
        h[:rules].each do |r|
          positions, moves, players = [], [], []

          p = r.new
          n.times do |i|
            positions[i] = p

            if p.final?
              moves[i], players[i] = nil, nil
              p = r.new
            else
              players[i] = p.has_moves[rand( p.has_moves.length )]
              moves[i] = 
                p.moves( players[i] )[rand( p.moves( players[i] ).length )]

              p = p.apply( moves[i], players[i] )
            end
          end

          x.report( "#{r} init" ) do
            n.times { r.new }
          end

          x.report( "#{r} position dup" ) do
            n.times { |i| positions[i].dup }
          end

          positions.each { |p| p.clear_cache } if h[:clear_cache]

          x.report( "#{r} move?" ) do
            n.times { |i| positions[i].move?( moves[i], players[i] ) }
          end

          positions.each { |p| p.clear_cache } if h[:clear_cache]

          x.report( "#{r} has_moves" ) do
            n.times { |i| positions[i].has_moves }
          end

          positions.each { |p| p.clear_cache } if h[:clear_cache]

          x.report( "#{r} moves" ) do
            n.times { |i| positions[i].moves( players[i] ) }
          end

          positions.each { |p| p.clear_cache } if h[:clear_cache]

          x.report( "#{r} apply" ) do
            n.times do |i| 
              positions[i].apply( moves[i], players[i] ) if moves[i]
            end
          end

          positions.each { |p| p.clear_cache } if h[:clear_cache]

          x.report( "#{r} final?" ) do
            n.times { |i| positions[i].final? }
          end

          x.report( "#{r} random play" ) do
            p = r.new
            n.times do
              p = r.new if p.final?
              player = p.has_moves[rand( p.has_moves.length )]
              move = p.moves( player )[rand( p.moves( player ).length )] 
              p.apply!( move, player )
            end
          end
        end
      end
    end

    def self.game( h )

    end

    def self.board( h )

    end

  end
end

