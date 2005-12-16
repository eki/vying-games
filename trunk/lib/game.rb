
class Player
  attr_reader :name, :short

  def initialize( name, short=nil )
    @name, @short = name, short || name.downcase[0..0]
  end

  def eql?( player )
    name == player.name && short == player.short
  end

  def ==( player )
    eql?( player )
  end

  def hash
    19 + short.hash * 37 +
         name.hash  * 37
  end

  def to_s
    "#{name} (#{short})"
  end

  def Player.method_missing( method_id, *args )
    name = method_id.to_s
    Player.new( name.capitalize, name.downcase[0..0] )
  end
end

class PlayerSet
  attr_reader :players

  def initialize( *p )
    @players = Array.new( p )
    @players.freeze

    @current = 0
  end

  def name
    players[@current].name
  end

  def short
    players[@current].short
  end

  def eql?( player )
    name == player.name && short == player.short
  end

  def ==( player )
    eql?( player )
  end

  def hash
    players[@current].hash
  end

  def current
    players[@current]
  end

  def next
    players[@current+1 < players.length ? @current+1 : 0]
  end

  def next!
    @current = @current+1 < players.length ? @current+1 : 0
    self
  end

  def previous
    players[@current > 0 ? @current-1 : players.length-1]
  end

  def previous!
    @current = @current > 0 ? @current-1 : players.length-1
    self
  end

  def to_s
    current.to_s
  end
end

class Op
  attr_accessor :name, :short, :action

  def initialize( name=nil, short=nil, &action )
    @name, @short, @action = name, short, action
  end

  def call
    action.call
  end

  def to_s
    s = "#{name} (#{short})"
  end

  def <=>( op )
    self.to_s <=> op.to_s
  end
end

class Struct
  def initialize_copy( original )
    original.each_pair { |k,v| self[k] = v.dup }
  end
end

class Game

  attr_reader :rules, :history, :sequence

  def initialize( rules )
    @rules, @history, @sequence = rules, [rules.init], []
  end

  def method_missing( method_id, *args )
    if history.last.respond_to?( method_id )
      return history.last.send( method_id )
    end
    Kernel.method_missing( method_id, *args )
  end

  def players
    rules.players
  end

  def ops
    @ops_cache = rules.ops( history.last )
  end

  def <<( op )
    @ops_cache ||= ops
    if @ops_cache.include?( op )
      @history  << op.call
      @sequence << op
      @ops_cache = nil
      return self
    else
      @ops_cache.each do |o|
        return self << o if o.short == op
      end
    end
    raise "#{op} not a valid operation"
  end

  def final?
    rules.final?( history.last )
  end

  def winner?( player )
    rules.winner?( history.last, player )
  end

  def loser?( player )
    rules.loser?( history.last, player )
  end

  def draw?
    rules.draw?( history.last )
  end

  def score( player )
    rules.score( history.last, player )
  end

  def to_s
    rules.to_s( history.last )
  end
end

