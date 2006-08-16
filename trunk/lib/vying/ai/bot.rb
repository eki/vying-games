require 'vying/user'

class Bot < UserDelegate

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

