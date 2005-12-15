$:.unshift File.join( File.dirname( __FILE__ ), "..", "lib" )

require 'game'

class HumanBot

  def HumanBot.select( game )
    ops = game.ops

    shorts = []
    ops.each { |op| shorts << op.short }

    puts game
    ops.each { |op| puts "op: #{op.short}" }
    print "Select: "

    while true 
      s = STDIN.gets.chomp
      return s if shorts.include?( s )
      puts "(#{s}) is an invalid selection"
      print "Select: "
    end
  end

end

