require 'game'

class LineBot < Bot

  attr_reader :patterns

  def initialize( game, player )
    super( game, player )

    opps = game.players.select { |p| p != player }

    p = player.to_s[0..0].downcase

    @patterns = { /(#{p}+)/ => 2 }

    opps.each do |opp|
      o = opp.to_s[0..0].downcase
      @patterns[/(#{o}+)#{p}/] = 3
    end
  end

  def select
    best( analyze( interesting_ops ) )
  end

  def evaluate( position )
    opps = game.players.select { |p| p != player }

    b = position.board

    score = 0
    occupied_lines( b ).each do |line| 
      patterns.each_pair do |p,v| 
        if b.to_s( line ) =~ p
          score += v ** ($1.length)
        end
      end
    end

    score
  end

  def occupied_lines( board )
    lines = []
    board.coords.each do |c|
      unless board[c].nil?
        lines << board.coords.row( c )
        lines << board.coords.column( c )
        lines << board.coords.diagonal( c, 1 )
        lines << board.coords.diagonal( c, -1 )
      end
    end
    lines.uniq
  end

  def interesting_ops( ops=game.ops, board=game.board )
    cs = []
    board.coords.each do |c|
      cs << board.coords.radius( c, 2 ) unless board[c].nil?
    end
    cs.flatten!.uniq!
    cs = cs.map { |c| c.to_s }
    ops.select { |op| cs.include?( op ) }
  end

end

