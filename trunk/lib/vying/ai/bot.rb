require 'vying/rules'

module AI
end

class Bot

  attr_reader :user_id, :username

  def initialize
    @user_id, @username = 0, self.class.to_s
  end

  def select( sequence, position, player )
    return position.ops.first if position.ops.length == 1

    score, op = best( analyze( position, player ) )
    op
  end

  def analyze( position, player )
    h = {}
    position.ops.each { |op| h[op] = evaluate( position.apply( op ), player ) }
    h
  end

  def best( scores )
    scores.invert.max
  end

  # Replace this implementation with a better one
  def fuzzy_best( scores )
    a = scores.invert
    s = a.map { |score,op| score }
    half_sd = standard_deviation( s ) / 2.0
    a2 = a.select { |score,op| ( score - s.max ).abs < half_sd }
    !a2.empty? ? a2[rand(a2.length)] : a.max
  end

  def to_s
    self.class.to_s
  end

  def name
    to_s =~ /(::)*(\w+)$/
    $2
  end

  def Bot.name
    to_s =~ /(::)*(\w+)$/
    $2
  end

  def Bot.require_all( path=$: )
    required = []
    path.each do |d|
      Dir.glob( "#{d}/**/bots/**/*bot.rb" ) do |f|
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

  def variance(population)
    n = 0
    mean = 0.0
    s = 0.0
    population.each do |x|
      n = n + 1
      delta = x - mean
      mean = mean + (delta / n)
      s = s + delta * (x - mean)
    end
    return s / n
  end

  def standard_deviation(population)
    Math.sqrt(variance(population))
  end 

end

