
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

end

class Game
  class State < Hash
    def initialize( h )
      h.each { |k,v| self[k] = v }
    end

    def initialize_copy( original )
      original.each { |k,v| self[k] = v.dup }
    end

    def method_missing( method_id, *args )
      name = method_id.to_s

      return self[name] if self.has_key?( name )
      Kernel.method_missing( method_id, args )
    end
  end

  attr_reader :rules, :history, :sequence

  def initialize( rules )
    @rules, @history, @sequence = rules, [State.new( rules.init )], []
  end

  def initialize_copy( game )
    
  end

  def method_missing( method_id, *args )
    return history.last.method_missing( method_id, args )
  end

  def players
    rules.players
  end

  def ops
    @ops_cache = rules.ops( self )
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
    rules.final?( self )
  end

  def winner?( player )
    rules.winner?( self, player )
  end

  def loser?( player )
    rules.loser?( self, player )
  end

  def draw?
    rules.draw?( self )
  end

  def score( player )
    rules.score( self, player )
  end

  def to_s
    rules.to_s( self )
  end
end

