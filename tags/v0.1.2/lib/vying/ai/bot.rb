require 'vying/rules'

module AI

  class Bot
    attr_reader :id, :username

    def initialize
      @id, @username = 0, self.class.to_s
    end

    def select( sequence, position, player )
      return position.ops.first if position.ops.length == 1
  
      score, op = best( analyze( position, player ) )
      op
    end

    def analyze( position, player )
      h = {}
      position.ops.each do |op|
        h[op] = evaluate( position.apply( op ), player )
      end
      h
    end

    def best( scores )
      scores = scores.invert
      m = scores.max
      puts "scores: #{scores.inspect} (taking #{m.inspect})"
      m
    end

    def fuzzy_best( scores, delta )
      s = []
      scores.each { |op,score| s << [score,op] }
      m = s.max
      ties = s.select { |score,op| (score - m.first).abs <= delta }
      m = ties[rand(ties.length)]
      puts "scores: #{s.inspect}, t: #{ties.inspect} (taking #{m.inspect})"
      m
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

# This is just a simple dummy Human bot class.  It can be used as a placeholder
# in Game#user_map
#
# ops taken from whatever UI, can use << to make them available via #select

  class Human < Bot
    attr_reader :queue

    def initialize
      @queue = []
    end

    def <<( op )
      queue << op
    end

    def select( sequence, position, player )
      queue.shift
    end

    def bot?
      false
    end
  end

end
