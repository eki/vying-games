# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# This is a straight port of the old AmazonsBoard code.  This plugin is only
# useful for Amazons.
#
# TODO:  Replace with a generalized Territory plugin.  The generalized plugin
#        should allow for the definition of what pieces a territory is
#        composed_of and delimited_by.  It should also allow for tracking
#        the access of certain pieces to a territory.  That is, for Amazons,
#        territory would be:
#
#          composed_of:    nil  (empty squares)
#          delimited_by:   [:black, :white, :arrow]
#          track:          [:black, :white]
#
#        So, :black and :white queens would (along with :arrow) delimit 
#        territory, but we would also track which territories they are
#        adjacent to.
#
# TODO:  This plugin also defines mobility and blocked lists.  These should
#        be pulled out into a separate plugin.
#
# The original AmazonsBoard comments have been left in place.

module Board::Plugins::Amazons
           
  # An AmazonsBoard Territory is block of connected (8-way) empty squares on an
  # AmazonsBoard.  The properties white and black represent the queens that are
  # attached to the territory.  For a queen to be attached to a territory it
  # must border at least one empty square that's in that territory.
  #
  # Note that the square occupied by the queen is not considered a part of the 
  # territory.

  class Territory
    attr_reader :white, :black, :coords

    def initialize( board, coords, queens=nil )
      if queens.nil?
        @white = board.occupied[:white].dup
        @black = board.occupied[:black].dup
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
      def []( board, coords )
        t = new board, coords
        t.update board
      end
    end

    def update( board )
      coords.reject! { |c| ! board[c].nil? }

      return self if coords.empty?

      queens_found, coords_found = check( board, coords.first )

      @white = queens_found.select { |q| board[q] == :white }
      @black = queens_found.select { |q| board[q] == :black }

      not_found = coords - coords_found

      @coords = coords_found

      if not_found.empty?
        return self
      else
        return [self, Territory[board, not_found]]
      end

    end

    # board[start] must be nil

    def check( board, start )
      raise "Territory#check: board[start] must be nil" unless board[start].nil?

      coords_found, todo = [start], [start]
      all = { start => start }
      queens_found = []

      while (c = todo.pop)
        board.coords.neighbors( c ).each do |nc|
          unless all[nc]
            all[nc] = nc

            if board[nc].nil? 
              todo.push nc
              coords_found.push nc
            elsif board[c].nil? && (board[nc] == :black || board[nc] == :white)
              queens_found.push nc
            end
          end
        end
      end

      return [queens_found, coords_found]
    end

    def move( sc, ec )
      if white.include?( sc )
        white.delete( sc )
        white << ec

        coords << sc
        coords.delete( ec )
      elsif black.include?( sc )
        black.delete( sc )
        black << ec

        coords << sc
        coords.delete( ec )
      end
    end

    def empty?
      coords.empty?
    end

    def eql?( o )
      return false if o.nil?

      if white.length != o.white.length ||
         black.length != o.black.length ||
         coords.length != o.coords.length
        return false
      end

      white.sort == o.white.sort &&
      black.sort == o.black.sort &&
      coords.sort == o.coords.sort
    end

    def ==( o )
      eql? o
    end

    def hash
      [white.sort, black.sort, coords.sort].hash
    end

  end

  attr_reader :territories, :mobility, :blocked

  def init_plugin
    super

    @territories = [Territory.new( self, coords.to_a.dup )]
    @mobility = {}
    @blocked = {}
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

  def fill( p )
    super
    @territories.clear
    @mobility.clear
    @blocked.clear
  end

  def after_set( x, y, p )
    if @move.nil? && (p == :black || p == :white)
      c = Coord[x,y]

      @territories.each do |t|
        if t.coords.include?( c )
          t.coords.delete( c )
          t.black << c if p == :black
          t.white << c if p == :white
        end
      end

      update_mobility( occupied[:black] + occupied[:white] )
    end
  end

  def move( sc, ec )
    @move = true

    super

    shared = @territories.select do |t|
      t.black.include?( sc ) || t.white.include?( sc )
    end

    if shared.length > 1
      @territories = @territories.map do |t| 
        t.move( sc, ec ) if t.black.include?( sc ) || t.white.include?( sc )
        t.update( self )
      end
      @territories.flatten!
      @territories.uniq!

    else
      @territories = @territories.map do |t| 
        t.move( sc, ec ) if t == shared.first 
        t.update( self )
      end
      @territories.flatten!
    end

    mobility[ec] = mobility.delete( sc )

    a = []
    mobility.each { |k,v| a << k if v.include?( ec ) }
    blocked.each  { |k,v| a << k if v.include?( sc ) }
    update_mobility( a )

    @move = nil

    self
  end

  def arrow( *ecs )
    self[*ecs] = :arrow
    
    @territories = @territories.map { |t| t.update( self ) }
    @territories.flatten!
    @territories.reject! { |t| t.empty? }

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
    super

    props = instance_variables
    props.delete( "@mobility" )
    props.delete( "@blocked" )
    props
  end

  def yaml_initialize( t, v )
    super

    @mobility = {}
    @blocked = {}
    update_mobility( occupied[:black] )
    update_mobility( occupied[:white] )
  end

end

