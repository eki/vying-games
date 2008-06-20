
class OpeningBook

  class Line
    attr_accessor :frequency
    attr_reader :sequence, :moves

    def initialize( sequence, moves=[] )
      @frequency, @sequence, @moves = 1, sequence, moves
    end
  end

  def initialize
    @openings = { "" => Line.new( "" ) }
  end

  def add( game, limit=10 )
    i = 1
    while i < game.sequence.length
      s = game.sequence[0,i]
      sk = s.join( "," )

      if @openings.key?( sk )
        @openings[sk].frequency += 1
      else
        line = Line.new( s )
        @openings[sk] = line
      end

      previous = s[0,i-1].join( "," )
      if @openings.key?( previous ) &&
         ! @openings[previous].moves.include?( s.last )
        @openings[previous].moves << s.last
      end

      break if i > limit

      i += 1
    end
  end

  def lines
    @openings.values
  end

  def line( sequence )
    sequence = sequence.join( "," ) if sequence.respond_to?( :join )
    @openings[sequence]
  end

  def trim( frequency_limit )
    @openings.reject! { |k,line| line.frequency < frequency_limit }
  end

  def chop
    @openings.reject! { |k,line| line.moves.empty? }
  end

  def moves( sequence )
    line = line( sequence )
    line ? line.moves : []
  end

  def inspect
    "#<OpeningBook size: #{lines.length}>"
  end

  def save( filename )
    open( filename, "w" ) do |f|
      f.write( to_yaml )
    end
  end

  def self.load( filename )
    book = nil
    open( filename, "r" ) do |f|
      book = YAML.load( f.read )
    end
    book
  end

end

