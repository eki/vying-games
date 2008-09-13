
require 'test/unit'
require 'vying'

class TestBoard < Test::Unit::TestCase

  def test_initialize
    b = Board.rect( :width => 7, :height => 6 )
    assert_equal( :rect, b.shape )
    assert_equal( 7, b.width )
    assert_equal( 6, b.height )
    assert_equal( nil, b.length )
    assert_equal( [], b.coords.omitted )

    b = Board.square( :length => 8 )
    assert_equal( :square, b.shape )
    assert_equal( 8, b.width )
    assert_equal( 8, b.height )
    assert_equal( 8, b.length )
    assert_equal( [], b.coords.omitted )

    b = Board.square( :length => 8, :omit => [:d3, :d4] )
    assert_equal( :square, b.shape )
    assert_equal( 8, b.width )
    assert_equal( 8, b.height )
    assert_equal( 8, b.length )
    assert_equal( ['d3', 'd4'], b.coords.omitted.map { |c| c.to_s }.sort )
    assert_equal( 62, b.coords.length )
    assert( ! b.coords.include?( Coord[:d3] ) )
    assert( ! b.coords.include?( Coord[:d4] ) )

    b = Board.triangle( :length => 4 )
    assert_equal( :triangle, b.shape )
    assert_equal( 4, b.width )
    assert_equal( 4, b.height )
    assert_equal( 4, b.length )
    assert_equal( 10, b.coords.length )
    assert_equal( 6, b.coords.omitted.length )
    assert_equal( ["a1", "a2", "a3", "a4", "b1", "b2", "b3", "c1", "c2", "d1"],
                  b.coords.map { |c| c.to_s }.sort )
    assert_equal( ["b4", "c3", "c4", "d2", "d3", "d4"],
                  b.coords.omitted.map { |c| c.to_s }.sort )

    b = Board.triangle( :length => 4, :omit => ["a1", "d1"] )
    assert_equal( :triangle, b.shape )
    assert_equal( 4, b.width )
    assert_equal( 4, b.height )
    assert_equal( 4, b.length )
    assert_equal( 8, b.coords.length )
    assert_equal( 8, b.coords.omitted.length )
    assert_equal( ["a2", "a3", "a4", "b1", "b2", "b3", "c1", "c2"],
                  b.coords.map { |c| c.to_s }.sort )
    assert_equal( ["a1", "b4", "c3", "c4", "d1", "d2", "d3", "d4"],
                  b.coords.omitted.map { |c| c.to_s }.sort )

    b = Board.rhombus( :width => 4, :height => 5 )
    assert_equal( :rhombus, b.shape )
    assert_equal( 4, b.width )
    assert_equal( 5, b.height )
    assert_equal( nil, b.length )
    assert_equal( [], b.coords.omitted )

    b = Board.hexagon( :length => 4 )
    assert_equal( :hexagon, b.shape )
    assert_equal( 7, b.width )
    assert_equal( 7, b.height )
    assert_equal( 4, b.length )
    assert_equal( 37, b.coords.length )
    assert_equal( 12, b.coords.omitted.length )
    assert_equal( ["a1", "a2", "a3", "a4", "b1", "b2", "b3", "b4", "b5", "c1",
                   "c2", "c3", "c4", "c5", "c6", "d1", "d2", "d3", "d4", "d5",
                   "d6", "d7", "e2", "e3", "e4", "e5", "e6", "e7", "f3", "f4",
                   "f5", "f6", "f7", "g4", "g5", "g6", "g7"],
                  b.coords.map { |c| c.to_s }.sort )

    assert_equal( ["a5", "a6", "a7", "b6", "b7", "c7", "e1", "f1", "f2", "g1",
                   "g2", "g3"],
                  b.coords.omitted.map { |c| c.to_s }.sort )

    b = Board.square( :length => 5, :cell_shape => :triangle )
    assert_equal( :square, b.shape )
    assert_equal( :triangle, b.cell_shape )

    assert_raise( ArgumentError ) do
      Board.new
    end

    assert_raise( RuntimeError ) do
      Board.new( {} )
    end

    assert_raise( RuntimeError ) do
      Board.new( :length => 4 )
    end

    assert_raise( RuntimeError ) do
      Board.new( :width => 4, :height => 5 )
    end

    assert_raise( RuntimeError ) do
      Board.new( :shape => :square )
    end

    assert_raise( RuntimeError ) do
      Board.new( :shape => :square, :height => 4 )
    end

    assert_raise( RuntimeError ) do
      Board.new( :shape => :triangle, :width => 4, :height => 4 )
    end

    assert_raise( RuntimeError ) do
      Board.new( :shape => :rhombus, :length => 4 )
    end

    assert_raise( RuntimeError ) do
      Board.new( :shape => :hexagon, :width => 4, :height => 4 )
    end
  end

  def test_bad_subscripts
    b = Board.new( :shape => :rect, :width => 7, :height => 6 )
    assert_equal( nil, b[-1,0] )
    assert_equal( nil, b[0,-1] )
    assert_equal( nil, b[-1,-1] )
    assert_equal( nil, b[7,0] )
    assert_equal( nil, b[7,6] )
    assert_equal( nil, b[0,6] )
    assert_equal( :black, b[0,6] = :black )
    assert_equal( nil, b[0,6] )
    assert_equal( nil, b[nil] )
  end

  def test_ci
    b = Board.new( :shape => :rect, :width => 7, :height => 6 )
    assert_equal( 0, b.ci( 0, 0 ) )
    assert_equal( 2, b.ci( 2, 0 ) )
    assert_equal( 14, b.ci( 0, 2 ) )
    assert_equal( 17, b.ci( 3, 2 ) )
  end

  def test_dup
    b = Board.new( :shape => :rect, :width => 7, :height => 6 )

    assert_equal( :black, b[3,4] = :black )
    b2 = b.dup

    assert_equal( :black, b2[3,4] )
    assert_equal( :white, b2[0,0] = :white )
    assert_equal( nil, b[0,0] )
    assert_equal( :black, b[1,1] = :black )
    assert_equal( nil, b2[1,1] )
    assert_not_equal( b, b2 )

    assert_equal( :black, b2[1,1] = :black )
    assert_equal( :white, b[0,0] = :white )
    assert_equal( b, b2 )

    assert_equal( :blue, b[0,0] = :blue )
    assert_equal( :red, b[0,1] = :red   )

    assert_equal( :red, b2[0,0] = :red   )
    assert_equal( :blue, b2[0,1] = :blue )

    assert_equal( nil, b2[0,0] = nil )
    assert_equal( nil, b2[0,1] = nil )

    assert_not_equal( b, b2 )  # Are they sharing key?
  end

  def test_assignment
    b = Board.new( :shape => :rect, :width => 7, :height => 6 )
    assert_equal( nil, b[3,4] )
    assert_equal( :black, b[3,4] = :black )
    assert_equal( :black, b[3,4] )

    assert_equal( nil, b[:a1] )
    assert_equal( :white, b[:a1] = :white )
    assert_equal( :white, b[:a1] )

    assert_equal( nil, b[Coord[2,2]] )
    assert_equal( :white, b[Coord[2,2]] = :white )
    assert_equal( :white, b[Coord[2,2]] )

    assert_equal( [:black,:white,nil,:white], b[[3,4],:a1,:b2,Coord[2,2]] )
  end

  def test_in_bounds
    b = Board.new( :shape => :rect, :width => 7, :height => 6 )
    assert( b.in_bounds?( 0, 0 ) )
    assert( b.in_bounds?( 6, 0 ) )
    assert( b.in_bounds?( 0, 5 ) )
    assert( b.in_bounds?( 6, 5 ) )

    assert_nil( b.in_bounds?( -1, 0 ) )
    assert_nil( b.in_bounds?( 0, -1 ) )
    assert_nil( b.in_bounds?( 7, 0 ) )
    assert_nil( b.in_bounds?( 0, 6 ) )
  end

  def test_equals
    b1 = Board.new( :shape => :rect, :width => 7, :height => 6 )
    b2 = Board.new( :shape => :rect, :width => 7, :height => 6 )
    b3 = Board.new( :shape => :rect, :width => 6, :height => 7 )
    b4 = Board.new( :shape => :rect, :width => 1, :height => 2 )

    assert_equal( b1, b2 )

    assert_not_equal( b1, b3 )
    assert_not_equal( b1, b4 )

    assert_equal( b1, b1.dup )

    assert_equal( :white, b2[3,3] = :white )
    assert_not_equal( b1, b2 )

    assert_equal( :white, b1[3,3] = :white )
    assert_equal( b1, b2 )

    assert_equal( :blue, b1[3,4] = :blue )   # :blue added to key
    assert_equal( :red,  b2[3,4] = :red  )   # :red  added to key

    assert_not_equal( b1, b2 )
  end

  def test_hash
    b1 = Board.new( :shape => :rect, :width => 7, :height => 6 )
    
    assert_equal( :black, b1[:a1,:a2,:b4,:e3] = :black )

    b2 = b1.dup

    assert_equal( b1, b2 )
    assert_equal( b1.hash, b2.hash )
  end

  def test_count
    b = Board.new( :shape => :rect, :width => 3, :height => 4 )

    assert_equal( 0, b.count( :black ) )
    assert_equal( :black, b[:a1,:a2,:a3,:a4] = :black )
    assert_equal( 4, b.count( :black ) )

    assert_equal( 0, b.count( :white ) )
    assert_equal( :white, b[:b1,:b2,:b3,:b4,:c1,:c2,:c3,:c4] = :white )
    assert_equal( 8, b.count( :white ) )

    assert_equal( 0, b.count( :blue ) )
    assert_equal( :blue, b[:a2,:b3] = :blue )
    assert_equal( 2, b.count( :blue  ) )
    assert_equal( 3, b.count( :black ) )
    assert_equal( 7, b.count( :white ) )
  end

  def test_occupied
    b = Board.new( :shape => :square, :length => 4 )
    assert_equal( [], b.occupied[:black] )
    b[1,1] = :black
    assert_equal( [Coord[1,1]], b.occupied[:black] )
    assert_equal( [], b.occupied[:white] )
    b[1,1] = :white
    assert_equal( [], b.occupied[:black] )
    assert_equal( [Coord[1,1]], b.occupied[:white] )

    b.clear
    b[:a1] = :black
    assert_equal( [Coord[:a1]], b.occupied[:black] )   
    assert_equal( 15, b.occupied[nil].length )   
    assert( ! b.occupied[nil].include?( Coord[:a1] ) )   
    assert_nothing_raised { Marshal.dump( b ) }
  end

  def test_each
    b = Board.new( :shape => :square, :length => 2 )
    b[0,0] = :b00
    b[1,0] = :b10
    b[0,1] = :b01
    b[1,1] = :b11

    a = [:b00, :b10, :b01, :b11]
    i = 0

    b.each { |p| assert_equal( a[i], p ); i += 1 }
  end

  def test_each_from
    b = Board.new( :shape => :square, :length => 8 )
    b[3,3] = :x
    b[3,4] = :x
    b[3,6] = :x
    b[2,2] = :o
    b[1,1] = :o
    b[0,0] = :o

    count1 = b.each_from( Coord[3,3], [:nw,:s] ) { |p| !p.nil? }
    count2 = b.each_from( Coord[3,3], [:nw,:s] ) { |p| p == :x }
    count3 = b.each_from( Coord[3,3], [:nw] ) { |p| p == :x }
    count4 = b.each_from( Coord[3,3], [:nw,:s] ) { |p| p == :o }
    count5 = b.each_from( Coord[3,6], [:nw,:s,:e,:w] ) { |p| !p.nil? }

    assert_equal( 4, count1 )
    assert_equal( 1, count2 )
    assert_equal( 0, count3 )
    assert_equal( 3, count4 )
    assert_equal( 0, count5 )
  end

  def test_row
    b = Board.new( :shape => :rect, :width => 3, :height => 2 )

    assert_equal( [nil,nil,nil], b.row(0) )
    assert_equal( :black, b[:a1,:b1] = :black )
    assert_equal( [:black,:black,nil], b.row(0) )
  end

  def test_move
    b = Board.new( :shape => :square, :length => 3 )

    assert_equal( :x, b[0,0] = :x )
    assert_equal( :o, b[2,2] = :o )
    assert_equal( nil, b[1,1] )

    assert_equal( b, b.move( [0,0], [1,1] ) )

    assert_equal( nil, b[0,0] )
    assert_equal( :o, b[2,2] )
    assert_equal( :x, b[1,1] )

    assert_equal( b, b.move( [2,2], [1,1] ) )

    assert_equal( nil, b[0,0] )
    assert_equal( nil, b[2,2] )
    assert_equal( :o, b[1,1] )
  end

  def test_clear
    b = Board.new( :shape => :square, :length => 4 )
    assert_equal( 16, b.empty_count )
    assert_equal( :black, b[:a1,:a2,:a3] = :black )
    assert_equal( :white, b[:b1,:b2,:b3,:b4] = :white )
    assert_equal( 9, b.empty_count )
    assert_equal( 16, b.clear.empty_count )
  end

  def test_fill
    b = Board.new( :shape => :square, :length => 4 )
    assert_equal( 16, b.empty_count )
    b.fill( :black )
    assert_equal( 0, b.empty_count )
    assert_equal( 16, b.count( :black ) )
    b.fill( :white )
    assert_equal( 0, b.empty_count )
    assert_equal( 0, b.count( :black ) )
    assert_equal( 16, b.count( :white ) )
  end

  def test_to_s
    b = Board.new( :shape => :square, :length => 2 )
    b[0,0] = '0'
    b[1,0] = '1'
    b[0,1] = '2'
    b[1,1] = '3'
  
    assert_equal( " ab \n1011\n2232\n ab \n", b.to_s )

    b = Board.new( :shape => :rect, :width => 2, :height => 10 )
    b[0,0], b[1,0], b[0,9], b[1,9] = 'a', 'b', 'c', 'd'
    s = <<EOF
  ab  
 1ab1 
 2  2 
 3  3 
 4  4 
 5  5 
 6  6 
 7  7 
 8  8 
 9  9 
10cd10
  ab  
EOF

    assert_equal( s, b.to_s )
  end

  def test_find_plugin
    plugin = Board::Plugins::Frontier

    assert_equal( plugin, Board.find_plugin( plugin ) )
    assert_equal( plugin, Board.find_plugin( plugin.to_s.to_sym ) )
    assert_equal( plugin, Board.find_plugin( plugin.to_s ) )
    assert_equal( plugin, Board.find_plugin( "frontier" ) )
    assert_equal( plugin, Board.find_plugin( :frontier ) )

    plugin = Board::Plugins::CustodialFlip

    assert_equal( plugin, Board.find_plugin( plugin ) )
    assert_equal( plugin, Board.find_plugin( plugin.to_s.to_sym ) )
    assert_equal( plugin, Board.find_plugin( plugin.to_s ) )
    assert_equal( plugin, Board.find_plugin( "custodial_flip" ) )
    assert_equal( plugin, Board.find_plugin( :custodial_flip ) )

    assert_equal( nil, Board.find_plugin( nil ) )
    assert_equal( nil, Board.find_plugin( "nonexistant_plugin" ) )
    assert_equal( nil, Board.find_plugin( :nonexistant_plugin ) )
    assert_equal( nil, Board.find_plugin( "NonexistantPlugin" ) )
    assert_equal( nil, Board.find_plugin( :NonexistantPlugin ) )
  end

  def test_init_plugin
    b = Board.new( :shape   => :square, 
                   :length  => 4, 
                   :plugins => [:frontier, :in_a_row] )

    assert( (class << b; ancestors; end).include?( Board::Plugins::Frontier ) )
    assert_equal( [], b.frontier )

    assert( (class << b; ancestors; end).include?( Board::Plugins::InARow ) )
    assert_equal( [], b.threats )
    assert_equal( nil, b.window_size )
  end

  def test_triangle_cells
    b = Board.square( :length => 5, :cell_shape => :triangle )
    assert_equal( :triangle, b.cell_shape )

    assert_raise( RuntimeError ) { b.directions }
    assert_nothing_raised { b.directions( :a1 ) }

    assert_raise( RuntimeError ) do
      Board.square( :length     => 5, 
                    :cell_shape => :triangle, 
                    :directions => [:n,:e,:w,:s] )
    end

    assert_equal( [:w,:e,:s], b.directions( :a1 ) )
    assert_equal( [:n,:e,:w], b.directions( :b1 ) )
    assert_equal( [:w,:e,:s], b.directions( :c1 ) )
    assert_equal( [:n,:e,:w], b.directions( :d1 ) )
    assert_equal( [:w,:e,:s], b.directions( :e1 ) )

    assert_equal( [:n,:e,:w], b.directions( :a2 ) )
    assert_equal( [:w,:e,:s], b.directions( :b2 ) )
    assert_equal( [:n,:e,:w], b.directions( :c2 ) )
    assert_equal( [:w,:e,:s], b.directions( :d2 ) )
    assert_equal( [:n,:e,:w], b.directions( :e2 ) )

    assert_equal( [:w,:e,:s], b.directions( :a3 ) )
    assert_equal( [:n,:e,:w], b.directions( :b3 ) )
    assert_equal( [:w,:e,:s], b.directions( :c3 ) )
    assert_equal( [:n,:e,:w], b.directions( :d3 ) )
    assert_equal( [:w,:e,:s], b.directions( :e3 ) )

    assert_equal( ['a2','b1'], 
                  b.coords.neighbors( Coord[:a1] ).map { |c| c.to_s }.sort )
    assert_equal( ['a1','c1'], 
                  b.coords.neighbors( Coord[:b1] ).map { |c| c.to_s }.sort )
    assert_equal( ['b2','c1','d2'],
                  b.coords.neighbors( Coord[:c2] ).map { |c| c.to_s }.sort )
    assert_equal( ['a2','b3','c2'],
                  b.coords.neighbors( Coord[:b2] ).map { |c| c.to_s }.sort )
  end

end

