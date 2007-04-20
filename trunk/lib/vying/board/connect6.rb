require 'vying/board/board'

class Threat
  attr_reader :degree, :player, :empty_coords, :occupied

  def initialize( degree, player, empty_coords, occupied )
    @degree, @player = degree, player
    @empty_coords, @occupied = empty_coords, occupied
  end

  def to_s
    "[#{degree}, #{player}, #{empty_coords.inspect}]"
  end

  def inspect
    to_s
  end
end

class Connect6Board < Board

  attr_reader :threats, :window_size

  def initialize( window_size=6 )
    super( 19, 19 )
    @threats = []
    @window_size = window_size
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
    threats.reject! do |t|
      t.empty_coords.include?( c ) || t.occupied.include?( c )
    end

    windows = create_windows( c, [:n,:s] )
    windows += create_windows( c, [:e,:w] )
    windows += create_windows( c, [:ne,:sw] )
    windows += create_windows( c, [:nw,:se] )

    windows.each do |w|
      bc = w.select { |c| self[c] == :black }
      wc = w.select { |c| self[c] == :white }
      ec = w.select { |c| self[c].nil? }

      if bc.length + ec.length == window_size && ec.length < (window_size-1)
        threats << Threat.new( ec.length, :black, ec, bc )
      end

      if wc.length + ec.length == window_size && ec.length < (window_size-1)
        threats << Threat.new( ec.length, :white, ec, wc )
      end
    end

    threats
  end

  def create_windows( c, directions )
    n = window_size - 1

    first = (0..n).map do |i| 
      tmp = c
      i.times { tmp += Coords::DIRECTIONS[directions.first] }
      tmp
    end

    list = [first]

    n.times do 
      list << list.last.map { |c| c + Coords::DIRECTIONS[directions.last] }
    end

    list.select { |w| in_bounds?( w ) }
  end

  def in_bounds?( w )
    0 <= w.first.x && w.first.x < 19 && 0 <= w.first.y && w.first.y < 19 &&
    0 <= w.last.x  && w.last.x  < 19 && 0 <= w.last.y  && w.last.y  < 19
  end
end

