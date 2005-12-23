#!/usr/bin/ruby

require "optparse"

require 'match'

require 'rules/connectfour/connectfour'
require 'rules/connect6/connect6'
require 'rules/tictactoe/fifteen'
require 'rules/tictactoe/tictactoe'
require 'rules/othello/othello'

require 'ai/bots/humanbot'
require 'ai/bots/randombot'
require 'ai/bots/exhaustivebot'

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

players.each_pair do |p,v|
  puts "#{p}:#{v} not valid!" if !rules.players.include?( p )
end

m = Match.new( rules, players )
m.play( number )
puts m.to_s

