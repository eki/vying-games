# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Board::Plugins::InARow

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

  attr_reader :threats, :window_size

  def init_plugin
    super
    @threats = []
    @window_size = nil
  end

  def window_size=( n )
    old, @window_size = @window_size, n

    if n != old
      threats.clear
      pieces.each do |p|
        occupied( p ).each { |cs| cs.each { |c| update_threats( c.x, c.y ) } }
      end
    end
  end

  def initialize_copy( original )
    super
    @threats = original.threats.dup
  end

  def fill( p )
    super
    threats.clear
  end

  # The #update_threats method is called automatically after each set call.

  def after_set( x, y, p )
    super
    update_threats( x, y )
  end

  # Update #threats after a piece has been placed or removed.  There is no
  # need to call this manually.

  def update_threats( x, y )
    c, p = Coord[x,y], self[x,y]

    threats.reject! do |t|
      t.empty_coords.include?( c ) || t.occupied.include?( c )
    end

    windows = create_windows( c )

    windows.each do |w|
      pc, oc, ec = [], [], []

      w.each do |wc|
        if self[wc].nil?
          ec << wc
        elsif self[wc] == p
          pc << wc
        else
          oc << wc
        end
      end

      if pc.length + ec.length == window_size && ec.length < (window_size-1)
        threats << Threat.new( ec.length, p, ec, pc )
      end
    end

    threats
  end

  private 

  # Create threat windows.  There is no need to call this manually.

  def create_windows( c )
    n = window_size - 1

    dirs = [[:n,:s], [:e,:w], [:ne,:sw], [:nw,:se]]
    dirs.reject! { |ds| ! ds.all? { |d| directions.include?( d ) } }

    ws = []

    dirs.map do |ds|
      first = (0..n).map do |i| 
        tmp = c
        i.times { tmp += Coords::DIRECTIONS[ds.first] }
        tmp
      end

      list = [first]

      n.times do 
        list << list.last.map { |tmp| tmp + Coords::DIRECTIONS[ds.last] }
      end

      ws += list.select { |w| window_in_bounds?( w ) }
    end

    ws
  end

  # Is the given window in bounds.  There is no need to call this manually.

  def window_in_bounds?( w )
    if coords.omitted.empty?
      coords.include?( w.first ) && coords.include?( w.last )
    else
      w.all? { |c| coords.include?( c ) }
    end
  end

  # Does the given coord have a neighbor (piece)?  There is no need to call
  # this manually.

  def has_neighbor?( c )
    coords.neighbors( Coord[c] ).find { |n| ! self[n].nil? }
  end
end

