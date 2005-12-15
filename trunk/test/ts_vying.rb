$:.unshift File.join( File.dirname( __FILE__ ), "..", "lib" )

require "test/unit"

require "tc_game"

require "tc_board"

require "rules/tc_connectfour"
require "rules/tc_tictactoe"

