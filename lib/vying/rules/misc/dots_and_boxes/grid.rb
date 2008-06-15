
class Grid
  extend Memoizable

  class << self
    extend Memoizable
    memoize :new
  end

  attr_reader :width, :height, :dots, :lines, :boxes

  def initialize( width=6, height=6 )
    @width, @height = width, height

    @dots = (1..(width*height)).to_a.freeze
    @lines = {}
    @boxes = {}

    dots.each do |d|
      de = self.next( d, :e )
      line( d, de, false ) unless de.nil?
      
      ds = self.next( d, :s )
      line( d, ds, false ) unless ds.nil?

      dd = self.next( ds, :e )
      box( d, de, ds, dd, nil ) unless de.nil? || ds.nil? || dd.nil?
    end
  end

  def initialize_copy( original )
    @dots = original.dots
    @lines = original.lines.dup
    @boxes = original.boxes.dup
  end

  def []( *args )
    if args.length == 2
      line?( *args )
    elsif args.length == 4
      box?( *args )
    end
  end

  def []=( *args )
    if args.length == 3
      line( *args )
    elsif args.length == 5
      box( *args )
    end
  end

  def line( d1, d2, on=true )
    a = [d1, d2]
    raise "Attempt to define line with nil dot" if a.include?( nil )

    lines[a.sort.freeze] = on
  end

  def line?( d1, d2 )
    a = [d1, d2]
    return false if a.include?( nil )

    lines[a.sort]
  end

  def box( d1, d2, d3, d4, player=nil )
    a = [d1, d2, d3, d4]
    raise "Attempt to define box with nil dot" if a.include?( nil )

    boxes[a.sort.freeze] = player
  end

  def box?( d1, d2, d3, d4 )
    a = [d1, d2, d3, d4]
    return false if a.include?( nil )

    boxes[a.sort]
  end

  def will_complete_box?( d1, d2 )
    directions = (d1 - d2).abs == 1 ? [:s, :n] : [:e, :w]

    directions.each do |dir|
      d3, d4 = self.next( d1, dir ), self.next( d2, dir )
      return true if line?( d1, d3 ) && line?( d2, d4 ) && line?( d3, d4 )
    end

    false
  end

  def next( dot, dir )
    return nil if dot.nil?

    nd = dot + width if dir == :s && dot <= width * height - width 
    nd = dot - width if dir == :n && dot > width
    nd = dot + 1     if dir == :e && dot % width != 0
    nd = dot - 1     if dir == :w && dot % width != 1

    nd
  end

  def to_s
    s = ""
    dots.each do |d|
      divider = line?( d, self.next( d, :e ) ) ? "-" : " "
      s << sprintf( "%*d", 2, d )
      s << divider
      if d % width == 0
        s << "\n "
        (d-width+1).upto( d ) do |d2|
          d3 = self.next( d2, :s )
          d4 = self.next( d2, :e )
          d5 = self.next( d3, :e )
          divider = line?( d2, d3 ) ? "|" : " "
          s << divider << " "
          if box?( d2, d3, d4, d5 )
            s << box?( d2, d3, d4, d5 ).to_s[0..0]
          else
            s << " "
          end
        end
        s << "\n"
      end
    end
    s
  end

  def hash
    [dots, lines, boxes].hash
  end

  def eql?( o )
    o.class == Grid &&
    dots.length == o.dots.length &&
    lines == o.lines &&
    boxes == o.boxes
  end

  def ==( o )
    eql? o
  end

end

