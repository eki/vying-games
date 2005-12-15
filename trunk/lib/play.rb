#!/usr/bin/ruby

require "optparse"

require 'match'

require 'rules/connectfour'
require 'rules/tictactoe'

require 'bots/humanbot'
require 'bots/randombot'

rules = nil
players = {}
number = 1

opts = OptionParser.new
opts.on( "-r", "--rules RULES" ) { |r| rules = Kernel.const_get( r ) }
opts.on( "-n", "--number NUM" ) { |n| number = Integer(n) }
opts.on( "-pARG" ) do |p|
  p =~ /(.*)=(.*)/
  players[Player.new($1)] = Kernel.const_get( $2 )
end

opts.parse( ARGV )

m = Match.new( rules, players )
m.play( number )
puts m.to_s

