require 'json'
require 'vying/game'

class GameResults
  def to_json( *a )
    { 'type'          => 'GameResults',
      'rules'         => rules,
      'seed'          => seed,
      'sequence'      => sequence,
      'user_map'      => user_map,
      'win_lose_draw' => win_lose_draw,
      'scores'        => scores,
      'check'         => check }.to_json( *a )
  end
end

class Game
  def to_hash
    { 'type'     => 'Game',
      'rules'    => rules,
      'history'  => history,
      'sequence' => sequence,
      'user_map' => user_map }
  end

  def to_json( *a )
    to_hash.to_json( *a )
  end
end

class Rules
  def to_hash
    h = { 'type'    => 'Position',
          'rules'   => self.class.to_s,
          'players' => players,
          'final'   => final? }

    if final?
      h.merge!( 'winner' => players.select { |p| winner? p },
                'loser'  => players.select { |p| loser? p },
                'draw'   => draw? )
    else
      h.merge!( 'ops' => ops,
                'turn' => turn )
    end

    h.merge!( 'board' => board ) if respond_to? :board

    if has_score?
      h['score'] = {}
      players.each { |p| h['score'][p] = score( p ) }
    end

    h
  end

  def to_json( *a )
    to_hash.to_json( *a )
  end
end

class Connect6 < Rules
  def to_hash
    h = super
    if final?
      threat = board.threats.select { |t| t.degree == 0 }.first

      h.merge!( 'line' => threat.occupied )
    end
    h
  end
end

class Board
  def to_json( *a )
    pieces, board = self.to_a
    { 'type'   => 'Board',
      'width'  => coords.width,
      'height' => coords.height,
      'pieces' => pieces,
      'board'  => board }.to_json( *a )
  end

  # Not sure this is an appropriate implementation of to_a
  def to_a
    pieces = []
    array = cells.map do |c|
      pieces << c unless pieces.include? c
      pieces.index( c )
    end
    [pieces, array]
  end
end

