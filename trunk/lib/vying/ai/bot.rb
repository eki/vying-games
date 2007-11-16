require 'vying/rules'

class Bot
  attr_reader :id, :username

  def initialize
    @id, @username = 0, self.class.to_s
  end

  def ready?
    true
  end

  def delegate_for( position )
    if self.class.const_defined?( "#{position.class}".intern )
      self.class.const_get( "#{position.class}".intern ).new
    end
  end

  def select( sequence, position, player )
    return position.moves.first if position.moves.length == 1

    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :select )
      return delegate.select( sequence, position, player )
    end

    score, move = best( analyze( position, player ) )

    move 
  end

  def forfeit?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :forfeit? )
      return delegate.forfeit?( sequence, position, player )
    end

    false
  end

  def offer_draw?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :offer_draw? )
      return delegate.offer_draw?( sequence, position, player )
    end

    false
  end

  def accept_draw?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :accept_draw? )
      return delegate.accept_draw?( sequence, position, player )
    end

    false
  end

  def analyze( position, player )
    h = {}
    position.moves.each do |move|
      delegate = delegate_for( position )
      if delegate && delegate.respond_to?( :evaluate )
        h[move] = delegate.evaluate( position.apply( move ), player )
      else
        h[move] = evaluate( position.apply( move ), player )
      end
    end
    h
  end

  def best( scores )
    scores = scores.invert
    m = scores.max
    #puts "scores: #{scores.inspect} (taking #{m.inspect})"
    m
  end

  def fuzzy_best( scores, delta )
    s = []
    scores.each { |move,score| s << [score,move] }
    m = s.max
    ties = s.select { |score,move| (score - m.first).abs <= delta }
    m = ties[rand(ties.length)]
    #puts "scores: #{s.inspect}, t: #{ties.inspect} (taking #{m.inspect})"
    m
  end

  def to_s
    self.class.to_s
  end

  def name
    to_s
  end
  
  def Bot.name
    self.to_s
  end

  def Bot.require_all( path=$: )
    required = []
    path.each do |d|
      Dir.glob( "#{d}/**/bots/**/*.rb" ) do |f|
        f =~ /(.*)\/bots\/(.*\.rb)$/
        if ! required.include?( $2 ) && !f["_test"]
          required << $2
          require "#{f}"
        end
      end
    end
  end

  @@bots_list = []

  def self.inherited( child )
    if child.to_s =~ /(\w+)\:\:(\w+)/ 
      unless @@bots_list.any? { |b| b.to_s == $1 }
        @@bots_list << child
      end
    else
      @@bots_list << child
    end
  end

  def Bot.list( rules=nil )
    return @@bots_list.select { |b| b.to_s[rules.to_s] } if rules
    @@bots_list
  end

  def Bot.find( name )
    Bot.list.each do |b|
      return b if name.downcase == b.to_s.downcase ||
                  name.downcase == b.name.downcase
    end
    nil
  end

end

# This is just a simple dummy Human bot class.  It can be used as a placeholder
# in Game#user_map
#
# moves taken from whatever UI, can use << to make them available via #select

class Human < Bot
  attr_reader :queue

  def initialize
    @queue = []
  end

  def <<( move )
    queue << move 
  end

  def select( sequence, position, player )
    queue.shift
  end

  def forfeit?( sequence, position, player )
    queue.shift if queue.first == "forfeit"
  end

  def offer_draw?( sequence, position, player )
    queue.shift if queue.first == "offer_draw"
  end

  def accept_draw?( sequence, position, player )
    queue.shift if queue.first == "accept_draw"
  end

  def bot?
    false
  end
end

