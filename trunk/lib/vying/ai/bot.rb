require 'vying/rules'

module AI
end

class Bot

  attr_reader :user_id, :username

  def initialize
    @user_id, @username = 0, self.class.to_s
  end

  def select( position, player )
    score, op = best( analyze( position, player ) )
    op
  end

  def analyze( position, player )
    h = {}
    position.ops.each { |op| h[op] = evaluate( position.apply( op ) ) }
    h
  end

  def best( scores )
    scores.invert.max
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

end

