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

    h
  end

  def to_json( *a )
    to_hash.to_json( *a )
  end
end

class Othello < Rules
  def to_hash
    h = super

    h['count'] = { 'black' => board.count( :black ),
                   'white' => board.count( :white ) }

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
    array = coords.rows.map do |a| 
      a.map do |c| 
        p = self[c]
        pieces << p unless pieces.include? p
        pieces.index( p )
      end 
    end
    [pieces, array]
  end
end

