# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/board/board'
require 'vying/memoize'

class Territory
  attr_reader :white, :black, :coords

  def initialize( board, coords, queens=nil )
    if queens.nil?
      @white = board.occupied[:white]
      @black = board.occupied[:black]
    else
      @white = queens.select { |q| board[q] == :white }
      @black = queens.select { |q| board[q] == :black }
    end

    @coords = coords
  end

  def initialize_copy( original )
    super
    @white = original.white.dup
    @black = original.black.dup
    @coords = original.coords.dup
  end

  class << self
    def []( board, queens=nil )
      t = new board, [], queens
      t.update board, queens
    end
  end

  def update( board, queens=nil )
    if queens.nil?
      @white = board.occupied[:white]
      @black = board.occupied[:black]

      queens ||= white + black
    else
      @white = queens.select { |q| board[q] == :white }
      @black = queens.select { |q| board[q] == :black }
    end

    queens_found, coords_found = check( board, queens.first )

    if queens_found.length == queens.length
      @coords = coords_found
      return self
    else
      return [Territory.new( board, coords_found, queens_found ),
              Territory[board, queens - queens_found]]
    end

  end

  def check( board, start )
    queens_found, coords_found, all, todo = [], [], {start => start}, [start]

    while (c = todo.pop)
      p = board[c]
      if p.nil?
        coords_found.push c
      elsif p == :white || p == :black
        queens_found.push c
        coords_found.push c
      end

      board.coords.neighbors( c ).each do |nc|
        unless board[c] == :arrow || all[nc]
          todo.push( nc )
          all[nc] = nc
        end
      end
    end

    return [queens_found, coords_found]
  end

  def move( sc, ec )
    if white.include?( sc )
      white.delete( sc )
      white << ec
    elsif black.include?( sc )
      black.delete( sc )
      black << ec
    end
  end

  def eql?( o )
    white == o.white &&
    black == o.black &&
    coords == o.coords
  end

  def ==( o )
    eql? o
  end

end


class AmazonsBoard < Board
  attr_reader :territories, :mobility, :blocked
  prototype

  INIT_WQS = [Coord[0,3], Coord[3,0], Coord[6,0], Coord[9,3]]
  INIT_BQS = [Coord[0,6], Coord[3,9], Coord[6,9], Coord[9,6]]

  def initialize
    super( 10, 10 )

    self[*INIT_WQS] = :white
    self[*INIT_BQS] = :black

    @territories = [Territory.new( self, coords.to_a, INIT_WQS + INIT_BQS )]

    @mobility = {}
    @blocked = {}
    update_mobility( INIT_WQS + INIT_BQS )
  end

  def initialize_copy( original )
    super
    @territories = []
    original.territories.each { |t| @territories << t.dup }

    @mobility = {}
    original.mobility.each { |k,v| @mobility[k] = v.dup }

    @blocked = {}
    original.blocked.each { |k,v| @blocked[k] = v.dup }
  end

  def clear
    @territories.clear
    @mobility.clear
    @blocked.clear
    super
  end

  def move( sc, ec )
    super
    territories.each { |t| t.move( sc, ec ) }

    mobility[ec] = mobility.delete( sc )

    a = []
    mobility.each { |k,v| a << k if v.include?( ec ) }
    blocked.each  { |k,v| a << k if v.include?( sc ) }
    update_mobility( a )

    self
  end

  def arrow( *ecs )
    self[*ecs] = :arrow
    
    @territories = @territories.map { |t| t.update( self, t.white + t.black ) }
    @territories.flatten!
    @territories

    a = []
    ecs.each do |ec|
      mobility.each { |k,v| a << k if v.include?( ec ) }
    end
    update_mobility( a.uniq )

    self
  end

  def update_mobility( queens )
    queens.each do |c|
      mobility[c] ||= []
      mobility[c].clear

      blocked[c] ||= []
      blocked[c].clear

      [:n,:e,:s,:w,:ne,:nw,:se,:sw].each do |d|
        ic = c
        while (ic = coords.next( ic, d ))
          if self[ic].nil?
            mobility[c] << ic
          else
            blocked[c] << ic if self[ic] == :white || self[ic] == :black
            break
          end
        end
      end
    end
  end

  def territory( p )
    a = []
    territories.each do |t|
      a += t.coords if p == :white && t.white.length > 0
      a += t.coords if p == :black && t.black.length > 0
    end
    a
  end

  def to_yaml_properties
    props = instance_variables
    props.delete( "@mobility" )
    props.delete( "@blocked" )
    props
  end

  def yaml_initialize( t, v )
    v.each { |k,v| instance_variable_set( "@#{k}", v ) }

    @mobility = {}
    @blocked = {}
    update_mobility( occupied[:black] )
    update_mobility( occupied[:white] )
  end

end

