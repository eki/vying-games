
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
    short.hash ^ name.hash
    #19 + short.hash * 37 +
    #     name.hash  * 37
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

class PositionStruct < Struct
  def initialize_copy( original )
    nd = [Symbol, NilClass, Fixnum]
    original.each_pair { |k,v| self[k] = (nd.include?( v.class ) ? v : v.dup) }
  end

  def to_s
    s = ''
    each_pair do |n,v|
      if (vs = v.to_s) =~ /\n/
        s << "#{n.to_s.capitalize!}:\n#{vs}\n"
      else
        s << "#{n.to_s.capitalize!}: #{vs}\n"
      end
    end
    s
  end
end

class Rules
  @@info = {}
  @@players = {}

  def Rules.info( i={} )
    class_eval( "@@info[self] = i" )
    class << self; def info; @@info[self]; end; end
  end

  def Rules.position( *symbols )
    class_eval( "Position = PositionStruct.new( *symbols )" )
    class << self
      undef_method :position
    end
  end

  def Rules.players( p )
    class_eval( "@@players[self] = p" )
    class << self; def players; @@players[self]; end; end
    p
  end

  def Rules.score( position, player )
    return  0 if draw?( position )
    return  1 if winner?( position, player )
    return -1 if loser?( position, player )
  end

  def Rules.find( path=$: )
    required = []
    path.each do |d| 
      Dir.glob( "#{d}/rules/**/*.rb" ) do |f| 
        f =~ /(.*)\/rules\/(.*\.rb)$/
        if ! required.include?( $2 ) && !f["test_"] && !f["ts_"]
          required << $2
          require "#{f}"
        end
      end
    end 
  end

  @@rules_list = []

  def self.inherited( child )
    @@rules_list << child
  end

  def Rules.list
    @@rules_list
  end

end

class Bot
  attr_reader :game, :player

  def initialize( game, player )
    @game, @player = game, player
  end

  def select
    game.ops.first unless game.final?
  end

  def select!
    game << select
  end

  def select
    best( analyze )
  end

  def analyze( ops=game.ops )
    scores = ops.map do |op|
      evaluate( game.rules.apply( game.history.last, op ) )
    end
    scores.zip( ops ).sort.reverse
  end

  def best( scores, delta=0 )
    best_ops = []
    best_score = scores.first[0]

    scores.each { |s| s[0]+delta >=  best_score ? best_ops << s[1] : break }
    best_ops[rand(best_ops.length)]
  end

  def Bot.find( path=$: )
    required = []
    path.each do |d| 
      Dir.glob( "#{d}/**/bots/*.rb" ) do |f| 
        f =~ /(.*)\/bots\/(.*\.rb)$/
        if ! required.include?( $2 ) && !f["test_"] && !f["ts_"]
          required << $2
          require "#{f}"
        end
      end
    end 
  end

  @@bots_list = []

  def self.inherited( child )
    @@bots_list << child
  end

  def Bot.list
    @@bots_list
  end
end

class Game
  attr_reader :rules, :history, :sequence

  def initialize( rules, seed=nil )
    @rules, @history, @sequence = rules, [rules.init( seed )], []
    yield self if block_given?
  end

  def method_missing( method_id, *args )
    if history.last.respond_to?( method_id )
      return history.last.send( method_id )
    elsif rules.respond_to?( method_id )
      return rules.send( method_id, history.last, *args )
    end
    super.method_missing( method_id, *args )
  end

  def respond_to?( method_id )
    history.last.respond_to?( method_id ) ||
    rules.respond_to?( method_id ) ||
    super.respond_to?( method_id )
  end

  def append( op )
    if op?( op )
      @history << apply( op )
      @sequence << op
      return self
    end
    raise "#{op} not a valid operation"
  end

  def append_list( ops )
    i = 0
    begin
      ops.each { |op| append( op ); i += 1 }
    rescue
      i.times { undo }
    end
    self
  end

  def append_string( ops, regex=/,/ )
    append_list( ops.split( regex ) )
  end

  def <<( ops )
    if ops.kind_of? String
      return append_string( ops )
    elsif ops.kind_of? Enumerable
      return append_list( ops )
    else
      return append( ops )
    end
  end

  def undo
    [@history.pop,@sequence.pop]
  end

  def players
    rules.players
  end

  def to_s
    history.last.to_s
  end
end

# Requires all files that appear to be Rules/Bot on the standard library path
Rules.find
Bot.find

