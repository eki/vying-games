# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

class Bot < User

  def bot?
    true
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

  def request_undo?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :request_undo? )
      return delegate.request_undo?( sequence, position, player )
    end

    false
  end

  def accept_undo?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :accept_undo? )
      return delegate.accept_undo?( sequence, position, player )
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
    username || self.class.to_s
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
  @@bots_play = {}

  def self.inherited( child )
    if child.to_s =~ /(\w+)\:\:(\w+)/ 
      if @@bots_list.any? { |b| b.to_s == $1 }
        b = Bot.find( $1 )
        r = Rules.find( $2 )
        (@@bots_play[r] ||= []) << b
      else
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

  def Bot.play( rules )
    @@bots_play[Rules.find( rules )]
  end

  def Bot.find( name )
    Bot.list.each do |b|
      return b if name.downcase == b.to_s.downcase ||
                  name.downcase == b.name.downcase
    end
    nil
  end

  DIFFICULTY_LEVELS = { :easy   => 0,
                        :medium => 1,
                        :hard   => 2 }

  def self.difficulty( d=nil )
    @difficulty = DIFFICULTY_LEVELS[d]
    class << self 
      def difficulty_name; DIFFICULTY_LEVELS[@difficulty]; end
      def difficulty; @difficulty; end
    end
    d
  end

  def self.difficulty_for( rules )
    if self.const_defined?( "#{rules}".intern )
      d = self.const_get( "#{rules}".intern ).difficulty
      return DIFFICULTY_LEVELS.invert[d] if d && DIFFICULTY_LEVELS.invert[d]
    end
    return :unknown
  end

end

# This is just a simple dummy Human bot class.  It accepts moves into a 
# queue via #<< and then plays them when asked for a move by Game#step and
# Game#play.
#

class Human < Bot
  attr_reader :queue

  def initialize( *args )
    super
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
    return   queue.shift if queue.first == "accept_draw"
    return ! queue.shift if queue.first == "reject_draw"
  end

  def request_undo?( sequence, position, player )
    queue.shift if queue.first == "request_undo"
  end

  def accept_undo?( sequence, position, player )
    return   queue.shift if queue.first == "accept_undo"
    return ! queue.shift if queue.first == "reject_undo"
  end

  def ready?
    ! @queue.empty?
  end

  def bot?
    false
  end
end

