require 'json'
require 'vying/game'

class GameResults
  def to_hash
    { 'rules'         => rules,
      'seed'          => seed,
      'sequence'      => sequence,
      'user_map'      => user_map,
      'win_lose_draw' => win_lose_draw,
      'scores'        => scores,
      'check'         => check }
  end

  def to_json( *a )
    { 'json_class' => self.class.name, 'data' => to_hash }.to_json( *a )
  end
end

class Game
  def to_hash
    { 'rules'    => rules,
      'history'  => history,
      'sequence' => sequence,
      'user_map' => user_map }
  end

  def to_json( *a )
    { 'json_class' => self.class.name, 'data' => to_hash }.to_json( *a )
  end
end

class Rules
  def to_hash
    hash = {}
    instance_variables.each do |iv|
      hash[iv[1,iv.length]] = instance_variable_get( iv )
    end
    hash
  end

  def to_json( *a )
    { 'json_class' => self.class.name, 'data' => to_hash }.to_json( *a )
  end
end

class Board
  def to_hash
    { 'board' => @board,
      'coords' => @coords }
  end

  def to_json( *a )
    { 'json_class' => self.class.name, 'data' => to_hash }.to_json( *a )
  end
end

class Coords
  def to_hash
    { 'width' => @width,
      'height' => @height,
      'coords' => @coords }
  end

  def to_json( *a )
    { 'json_class' => self.class.name, 'data' => to_hash }.to_json( *a )
  end
end

class Coord
  def to_hash
    { 'x' => @x,
      'y' => @y }
  end

  def to_json( *a )
    { 'json_class' => self.class.name, 'data' => to_hash }.to_json( *a )
  end

  def self.json_create( obj )
    new( obj['data']['x'], obj['data']['y'] )
  end
end

