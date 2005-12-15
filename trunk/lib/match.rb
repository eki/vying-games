
require 'game'

class Match

  attr_reader :rules, :players, :wins, :losses, :draws, :plays

  def initialize( rules, players={} )
    @rules = rules
    @players = players
    @wins = {}
    @losses = {}
    @draws = 0
    @plays = 0
  end

  def play( n=1 )
    n.times do
      g = Game.new( rules )
      g << players[g.turn].select( g ) until g.final?
      players.each_key do |p|
        @wins[p] ||= 0
        @losses[p] ||= 0
        @wins[p] += 1 if g.winner?( p )
        @losses[p] += 1 if g.loser?( p )
      end
      @draws += 1 if g.draw?
      @plays += 1
    end
  end

  def to_s
    s = "Plays: #{plays}\n"
    players.each_key do |p|
      s << "  #{p} (#{players[p]}): #{wins[p]}-#{losses[p]}-#{draws}\n"
    end
    s
  end

end

