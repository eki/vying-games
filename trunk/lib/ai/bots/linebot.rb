require 'game'

class LineBot < Bot

  attr_reader :patterns

  def initialize( game, player )
    super( game, player )

    opps = game.players.select { |p| p != player }

    p = player.short

    @patterns = {
      /#{p}/                     => 2,
      /#{p}#{p}/                 => 4,
      /#{p}#{p}#{p}/             => 16,
      /#{p}#{p}#{p}#{p}/         => 32,
      /#{p}#{p}#{p}#{p}#{p}/     => 64,
      /#{p}#{p}#{p}#{p}#{p}#{p}/ => 128,
      /^#{p}/                    => -1,
      /#{p}$/                    => -1,
    }

    opps.each do |opp|
      o = opp.short
      @patterns[/#{o}#{p}/] = -1
      @patterns[/#{o}#{p}#{p}/] = -2
      @patterns[/#{o}#{p}#{p}#{p}/] = -3
      @patterns[/#{o}#{p}#{p}#{p}#{p}/] = -4
      @patterns[/#{o}#{p}#{p}#{p}#{p}#{p}/] = -5
      @patterns[/#{p}#{o}/] = -1
      @patterns[/#{p}#{p}#{o}/] = -2
      @patterns[/#{p}#{p}#{p}#{o}/] = -3
      @patterns[/#{p}#{p}#{p}#{p}#{o}/] = -4
      @patterns[/#{p}#{p}#{p}#{p}#{p}#{o}/] = -5
      @patterns[/#{p}#{o}/] = 4
      @patterns[/#{p}#{o}#{o}/] = 32
      @patterns[/#{p}#{o}#{o}#{o}/] = 64
      @patterns[/#{p}#{o}#{o}#{o}#{o}/] = 128
      @patterns[/#{p}#{o}#{o}#{o}#{o}#{o}/] = 256
      @patterns[/#{o}#{p}/] = 4
      @patterns[/#{o}#{o}#{p}/] = 32
      @patterns[/#{o}#{o}#{o}#{p}/] = 64
      @patterns[/#{o}#{o}#{o}#{o}#{p}/] = 128
      @patterns[/#{o}#{o}#{o}#{o}#{o}#{p}/] = 256
    end

  end

  def select
    ops = game.ops
    scores = ops.map do |op| 
      pos = game.rules.apply( game.history.last, op )
      opps = game.players.select { |p| p != player }

      b = pos.board

      score = 0
      lines = b.coords.rows + b.coords.columns + 
              b.coords.diagonals( 1 ) + b.coords.diagonals( -1 )

      lines.each do |line| 
        patterns.each_pair do |p,v| 
          if b.to_s( line ) =~ p
            score += v
          end
        end
      end

      score
    end

    all = scores.zip( ops ).sort
    all.sort.last[1]
  end

end

