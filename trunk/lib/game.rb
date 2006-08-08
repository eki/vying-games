class Array
  def rotate!
    self << delete_at( 0 ) if size > 0
    self
  end

  def next
    self[1] if size > 1
  end

  def now
    self[0] if size > 0
  end
end

class PositionStruct < Struct
end

class Rules
  @@info = {}
  @@players = {}
  @@censored = {}

  def initialize_copy( original )
    nd = [Symbol, NilClass, Fixnum, TrueClass, FalseClass]
    instance_variables.each do |iv|
      v = instance_variable_get( iv )
      if !nd.include?( v.class )
        instance_variable_set( iv, v.dup )
      end
    end
  end

  def eql?( o )
    return false if instance_variables.sort != o.instance_variables.sort
    instance_variables.each do |iv|
      return false if instance_variable_get(iv) != o.instance_variable_get(iv)
    end
    true
  end

  def ==( o )
    eql?( o )
  end

  def Rules.info( i={} )
    class_eval( "@@info[self] = i" )
    class << self; def info; @@info[self]; end; end
  end

  def Rules.censor( h={}, p=nil )
    class_eval( "@@censored[self] = h" )
    class << self
      undef_method :censor
    end
  end

  def censor( player )
    pos = self.dup
    @@censored[self.class] ||= Hash.new( [] )
    @@censored[self.class][player].each do |f|
      pos.instance_eval( "@#{f} = :hidden" )
    end
    pos
  end

  def Rules.players( p )
    class_eval( "@@players[self] = p" )
    class << self; def players; @@players[self]; end; end
    p
  end

  def players
    @@players[self.class]
  end

  def op?( op, player=nil )
    (ops( player ) || []) .include?( op )
  end

  def draw?
    false
  end

  def score( player )
    return  0 if draw?
    return  1 if winner?( player )
    return -1 if loser?( player )
  end

  def has_ops
    return [turn.now] if respond_to? :turn
    []
  end

  def apply( op )
    self.dup.apply!( op )
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

  def to_s
    s = ''
    fs = instance_variables.map { |iv| iv.to_s.length }.max + 2
    instance_variables.each do |iv|
      v = instance_variable_get( iv )
      iv = iv.sub( /@/, '' )
      case v
        when Hash  then s += "#{iv}:".ljust(fs) + "#{v.inspect}\n"
        when Array then s += "#{iv}:".ljust(fs) + "#{v.inspect}\n"
        else
          s += "#{iv}:\n#{v}\n"               if v.to_s =~ /\n/
          s += "#{iv}:".ljust(fs) + "#{v}\n"  if v.to_s !~ /\n/
      end
    end
    s
  end
end

class Bot
  attr_reader :game, :player

  def initialize( game, player )
    @game, @player = game, player
  end

  def select!
    game << select
  end

  def select
    best( analyze )
  end

  def analyze( ops=game.ops )
    scores = ops.map do |op|
      evaluate( game.history.last.apply( op ) )
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
    @rules, @history, @sequence = rules, [rules.new( seed )], []
    yield self if block_given?
  end

  def method_missing( method_id, *args )
    if history.last.respond_to?( method_id )
      return history.last.send( method_id, *args )
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
    raise "'#{op}' not a valid operation"
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

