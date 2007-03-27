require 'vying/board/board'

class Threat
  attr_reader :degree, :player, :empty_coords

  def initialize( degree, player, empty_coords )
    @degree, @player, @empty_coords = degree, player, empty_coords
  end

  def to_s
    "[#{degree}, #{player}, #{empty_coords.inspect}]"
  end

  def inspect
    to_s
  end
end

class Connect6Board < Board

  attr_reader :threats

  def initialize
    super( 19, 19 )
    @threats = []
  end

  def initialize_copy( original )
    super
    @threats = original.threats.dup
  end

  def clear
    @threats.clear
    super
  end

  def update_threats( c )
    player = self[c]

    threats.reject! { |t| t.empty_coords.include?( c ) }

    windows = create_windows( c, [:n,:s] )
    windows += create_windows( c, [:e,:w] )
    windows += create_windows( c, [:ne,:sw] )
    windows += create_windows( c, [:nw,:se] )

    windows.each do |w|
      pc = w.select { |c| self[c] == player }
      ec = w.select { |c| self[c].nil? }

      if pc.length + ec.length == 6 && ec.length < 5
        threats << Threat.new( ec.length, player, ec )
      end
    end

    threats
  end

  def create_windows( c, directions )
    first = (0..5).map do |i| 
      tmp = c
      i.times { tmp += Coords::DIRECTIONS[directions.first] }
      tmp
    end

    list = [first]

    5.times do 
      list << list.last.map { |c| c + Coords::DIRECTIONS[directions.last] }
    end

    list.select { |w| in_bounds?( w ) }
  end

  def in_bounds?( w )
    0 <= w.first.x && w.first.x < 19 && 0 <= w.first.y && w.first.y < 19 &&
    0 <= w.last.x  && w.last.x  < 19 && 0 <= w.last.y  && w.last.y  < 19
  end
end

