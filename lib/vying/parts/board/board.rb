# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

# Board is a general purpose data structure for abstract board games.  It
# actually comes in a few varieties based on the overall shape of the board.
# For example, the board could be shaped like a square, rectangle, hexagon,
# or triangle.  While not really a shape, the board can also be infinite.
#
# To create a Board use one of the shape methods, for example:
#
#   b = Board.square( 8 )    # create a square board with sides 8 cells long
#
#   b = Board.hexagon( 4 )   # create a hexagon shaped tesselation of hexagons
#                            # -- each side is 4 cells long
#
#   b = Board.infinite( :cell_shape => :triangle )  # An infinite board of
#                                                   # triangles.
#
# There are several plugins available.  Plugins add functionality that isn't
# universally useful.  For example, Othello benefits from the frontier and
# custodial_flip plugins:
#
#   b = Board.square( 8, :plugins => [:frontier, :custodial_flip] )
#
# The frontier plugin, for example, wouldn't make sense as universal board code
# because it adds overhead to every #set call.

class Board

  attr_reader :shape, :cell_shape, :coords, :cells,
              :width, :height, :plugins

  protected :cells

  # Initialize a board.  Accepts a hash with the following parameters:
  #
  #   :omit - A list of coords to be excluded from the bounds of the board.
  #           Given param should be array.  All the elements will be mapped
  #           to Coord with Coord.[] so symbols and strings are acceptable.
  #
  #   :plugins - An array of plugins that the created board should extend.
  #              Plugins are typically modules under the Board::Plugins
  #              namespace.  Shorthand can be used to refer to the plugins
  #              in that namespace.  For example, Board::Plugins::Frontier
  #              can be referred to as :frontier.
  #

  def initialize(h) # :nodoc:
    omit = (h[:omit] || []).map { |c| Coord[c] }

    @origin ||= Coord[0, 0]

    @cells = Array.new(@width * @height, nil)
    @coords = CoordsProxy.new(self, Coords.new(bounds, omit))

    @occupied = Hash.new([])
    @occupied[nil] = @coords.to_a.dup

    @plugins = []

    (h[:plugins] || []).each { |p| plugin(p) }

    init_plugin

    fill(h[:fill]) if h[:fill]
  end

  # Create a square Board.

  def self.square(length, h={})
    Board::Square.new(length, h)
  end

  # Create a rect Board.

  def self.rect(width, height, h={})
    Board::Rect.new(width, height, h)
  end

  # Create a rhombus Board.

  def self.rhombus(width, height, h={})
    Board::Rhombus.new(width, height, h)
  end

  # Create a triangle Board.

  def self.triangle(length, h={})
    Board::Triangle.new(length, h)
  end

  # Create a hexagon Board.

  def self.hexagon(length, h={})
    Board::Hexagon.new(length, h)
  end

  # Create an infinite Board.

  def self.infinite(min_width=nil, min_height=nil, h={})
    Board::Infinite.new(min_width, min_height, h)
  end

  # Perform a deep copy on this board.

  def initialize_copy(original) # :nodoc:
    @cells = original.cells.dup
    @occupied = Hash.new([])
    occ = original.instance_variable_get('@occupied')
    occ.each { |k, v| @occupied[k] = v.dup }
  end

  # Initialize plugins.  The init_plugin method should be implemented by
  # any plugins that need to initialize instance variables.  All plugin
  # implementations should be sure to call super (or, else not all plugins
  # will be initialized).

  def init_plugin # :nodoc:
  end

  alias __dup dup # :nodoc:

  # Make a dup of this board.  If it has been extended by any plugins, dup
  # will re-extend the board prior to calling #intialize_copy.  Thus, plugins
  # can implement #initialize_copy as long as they call super.

  def dup # :nodoc:
    return __dup if plugins.empty?

    b = self.class.allocate

    instance_variables.each do |iv|
      b.instance_variable_set(iv, instance_variable_get(iv).deep_dup)
    end

    plugins.each { |p| b.extend(Board.find_plugin(p)) }

    b.send(:initialize_copy, self)
    b
  end

  # Boards can be indexed by an (x,y) pair, or any number of Coord-like
  # objects (ie, objects with #x and #y methods).  These Coord-like objects
  # include Symbol, String, Array, and, obviously, Coord.
  #
  # Example usage:
  #
  #   board[x,y]
  #   board[:symbol]
  #   board["string"]
  #   board[coord]
  #   board[coord1,coord2,...,coordn]
  #

  def [](*args)
    if args.length == 2 && args.first.kind_of?(Integer) &&
                           args.last.kind_of?(Integer)
      return get(args.first, args.last)
    elsif args.length == 1
      return args.first.nil? ? nil : get(args.first.x, args.first.y)
    else
      return args.map do |arg|
        get(arg.x, arg.y)
      end
    end

    nil
  end

  # Assign to a cell on a board.  Takes an (x,y) pair, or any number of
  # Coord-like objects.  If multiple coords are passed, they will all be
  # set to the same value.
  #
  # Example usage:
  #
  #   board[x,y] = :whatever
  #   board[coord] = :whatever
  #   board[coord1,coord2,...,coordn] = :whatever
  #

  def []=(*args)
    if args.length == 3 && args[0].kind_of?(Integer) &&
                           args[1].kind_of?(Integer)
      return set(args[0], args[1], args[2])
    elsif args.length == 2
      return args[0].nil? ? nil : set(args[0].x, args[0].y, args[1])
    else
      args.each { |arg| set(arg.x, arg.y, args.last) unless arg == args.last }
      return args.last
    end

    nil
  end

  # Returns the value at the given (x,y) coordinate.

  def get(x, y)
    if in_bounds?(x, y)
      return @cells[ci(x, y)]
    end

    nil
  end

  # Sets the piece p at the given (x,y) coordinate.  Plugins use the methods
  # after_set and before_set to observe set.  Most methods that modify the
  # state of the Board are routed through set.  The fill and clear methods are
  # exceptions to this rule.
  #
  # The pieces put on the board should be immutable.  Or, in the very least
  # *not* changed.  Good choices for pieces include symbols and fixnums, or
  # immutable objects like Counter.

  def set(x, y, p)
    if resize?(x, y)
      resize(x, y)
    end

    if in_bounds?(x, y)
      old = @cells[ci(x, y)]

      before_set(x, y, old)

      @occupied[old].delete(Coord.new(x, y))

      if @occupied[p].nil? || @occupied[p].empty?
        @occupied[p] = [Coord.new(x, y)]
      else
        @occupied[p] << Coord.new(x, y)
      end

      @cells[ci(x, y)] = p

      after_set(x, y, p)
    end

    p
  end

  # Translates (x,y) coordinates into an index for the underlying array.  You
  # shouldn't need this.

  def ci(x, y) # :nodoc:
    (x - @origin.x) + (y - @origin.y) * width
  end

  # Compare boards for equality.

  def ==(other)
    other.respond_to?(:cells, true) && other.respond_to?(:width, true) &&
    other.width == width && cells == other.cells
  end

  # Return a hash code for this board.

  def hash
    [cells, width].hash
  end

  # Return a count of pieces on the board.  If a piece is given, only that
  # pieces is counted.  If no piece is given, all pieces are counted.  Empty
  # cells are never counted (see #empty_count).

  def count(p=nil)
    return occupied(p).length if p
    @occupied.inject(0) { |m, v| m + (v[0] ? v[1].length : 0) }
  end

  # Count of empty (unoccupied) cells.  This is equivalent to calling
  # unoccupied.length.

  def empty_count
    @occupied[nil].length
  end

  # Move whatever piece is at the start coord (sc) to the end coord (ec).
  # If there was a piece at the end coord it is overwritten.

  def move(sc, ec)
    self[sc], self[ec] = nil, self[sc]
    self
  end

  # Get a list of all the pieces on the board.

  def pieces
    @occupied.keys.compact
  end

  # Get a list of all the coords of the cells occupied by the given piece,
  # or, if no piece is given, occupied by any piece.

  def occupied(p=nil)
    if p
      @occupied[p]
    else
      coords.coords - unoccupied
    end
  end

  # Get a list of the coords of unoccupied cells (that is the value at
  # the coord is nil).

  def unoccupied
    @occupied[nil]
  end

  # Iterate over each piece on the board.

  def each
    coords.each { |c| yield self[c] }
  end

  # Get the connectivity directions for the given Coord.  Note:  For most
  # boards this is a constant list so you don't have to provide a Coord.
  # However, if the cells are :triangle shaped, you *must* provide a Coord
  # or an exception will be raised.

  def directions(coord=nil)
    return @directions unless cell_shape == :triangle

    if coord.nil?
      raise 'Board#directions requires a Coord when cell_shape is :triangle'
    end

    if coord.y.even?
      coord.x.even? ? @up_directions : @down_directions
    else
      coord.x.even? ? @down_directions : @up_directions
    end
  end

  # Iterate over pieces from the start coord in the given directions.  The
  # start coord is not included.

  def each_from(s, directions)
    i = 0
    directions.each do |d|
      c = s
      while (c = coords.next(c, d)) && yield(self[c])
        i += 1
      end
    end
    i
  end

  # Clear all the pieces from the board.

  def clear
    fill(nil)
  end

  # Fill the entire board with the given piece.

  def fill(p)
    if coords.omitted.empty?
      cells.each_index { |i| cells[i] = p }

      @occupied = Hash.new([])
      @occupied[p] = @coords.to_a.dup
    else
      coords.each { |c| self[c] = p }
    end

    self
  end

  # Returns true if the given (x,y) coordinate is within the bounds of this
  # Board.  Note:  This doesn't mean the given coordinate is *actually* on the
  # Board.  It's possible that a coordinate within bounds has been omitted.  It
  # is probably safer to use Coords#include? as in:
  #
  #   board.coords.include?( Coord[x,y] )
  #

  def in_bounds?(x, y)
    if x < @origin.x || x >= @origin.x + width ||
       y < @origin.y || y >= @origin.y + height
      return nil
    end

    true
  end

  # Returns the bounds for this board expressed as two Coord objects.  For
  # example:
  #
  #   Board.square( 8 ).bounds  # => [a1, h8]
  #
  # This is usually fixed, but if the board is infinite the bounds will grow
  # to accomodate pieces that have been placed out of bounds.

  def bounds
    [@origin, Coord[@origin.x + @width - 1, @origin.y + @height - 1]]
  end

  # Can this board be resized to include (x,y).  The default implementation
  # always returns false.  Right now only Board::Infinite can be resized.

  def resize?(x, y)
    false
  end

  # Resize the board to include (x,y).  The default implementation raises
  # an error.  Right now only Board::Infinite implements resize.

  def resize(x, y)
    raise "This board doesn't support the resize operation."
  end

  # Is there a path between the two coords made up of cells occupied by
  # the same piece as the endpoints.

  def path?(c1, c2)
    check = [c1]
    checked = []
    p = self[c1]

    while c = check.pop
      return true if c == c2

      checked << c

      coords.neighbors(c).select { |nc| self[nc] == p }.each do |nc|
        check << nc unless checked.include?(nc)
      end
    end

    false
  end

  # Break the set of coords up into groups such that each group is both
  # occupied by the same piece and connected.

  def group_by_connectivity(cs)
    cs = cs.dup
    groups = []

    until cs.empty?
      check = [cs.first]
      group = []
      p = self[check.first]

      while c = check.pop
        cs.delete(c)
        group << c

        coords.neighbors(c).each do |nc|
          check << nc  if cs.include?(nc) && self[nc] == p
        end
      end

      group.uniq!

      groups << group
    end

    groups
  end

  # This can be overridden perform some action before a cell on the board is
  # overwritten (as with #[]=).  The given piece (p) is the value at the given
  # (x,y) coordinate before it's changed.

  def before_set(x, y, p)
  end

  # This can be overridden perform some action after a cell on the board has
  # been overwritten (as with #[]=).  The given piece (p) is the value at the
  # given (x,y) coordinate after it's been changed.

  def after_set(x, y, p)
  end

  # Returns a string representation of this Board.  This is simple
  # fixed-width ascii with one character per cell.  The character is the
  # first letter of the string representation of the piece in that cell.
  # The rows and columns are all labeled.

  def to_s
    off = height >= 10 ? 2 : 1
    w = width

    letters = ' ' * off + 'abcdefghijklmnopqrstuvwxyz'[0..(w - 1)] + ' ' * off + "\n"

    s = letters
    height.times do |y|
      row = (0...width).map { |x| cells[ci(x, y)] }

      s += format('%*d', off, y + 1)
      s += row.inject('') do |rs, p|
        rs + (p.nil? ? ' ' : p.to_s[0..0])
      end
      s += format("%*d\n", -off, y + 1)
    end
    s + letters
  end

  # When you ask for Board#coords you actually get a CoordsProxy object.  The
  # CoordsProxy simplifies some of the Coords method calls.  For example,
  # Coords#neighbors takes an optional directions array, CoordsProxy
  # automatically sets directions to the Board default.

  class CoordsProxy

    # CoordsProxy matches a Board with a Coords object.

    def initialize(board, coords) # :nodoc:
      @board, @coords = board, coords
    end

    # Calls Coords#ring but defaults the shape and directions correctly.

    def ring(coord, d)
      @coords.ring(coord, d, @board.cell_shape, @board.directions(coord))
    end

    # Calls Coords#neighbors but defaults directions correctly.

    def neighbors(coord, directions=nil)
      directions ||= @board.directions(coord)
      @coords.neighbors(coord, directions)
    end

    # Calls Coords#neighbors_nil but defaults directions correctly.

    def neighbors_nil(coord, directions=nil)
      directions ||= @board.directions(coord)
      @coords.neighbors_nil(coord, directions)
    end

    # Are the given coords all connected?  This checks that the list of coords
    # are connected (in terms of Board#directions and Coords#include?).
    #
    # Note:  This method is kind of difficult to place.  It's very intimate
    # with both Board (because it needs #directions) and, yet, it's really
    # more of a Coords method (because it needs Coords#include? and doesn't
    # depend on anything else from Board).

    def connected?(cs)
      cs = cs.dup
      check = [cs.first]

      while c = check.pop
        cs.delete(c)

        neighbors(c).each do |nc|
          check << nc  if cs.include?(nc)
        end
      end

      cs.empty?
    end

    # Can't be passed through with method_missing.

    def to_a # :nodoc:
      @coords.to_a
    end

    # Can't be passed through with method_missing.

    def to_s # :nodoc:
      @coords.to_s
    end

    # Can't be passed through with method_missing.

    def inspect # :nodoc:
      @coords.inspect
    end

    # Override respond_to? to match method_missing.

    def respond_to?(m, include_all=false) # :nodoc:
      # This was updated for ruby 2.0.  Evidently, I wrote this code with the
      # expectation that protected / private calls would be proxied.  This
      # strikes me as a bad idea, but this is a quick fix for now.
      #   (re: passing true to respond_to?)

      m != :_dump && (super || @coords.respond_to?(m, true))
    end

    # This is a proxy, so pass most method calls on to the proxied Coords.

    def method_missing(m, *args, &block) # :nodoc:
      if m != :_dump && @coords.respond_to?(m, true)
        @coords.send(m, *args, &block)
      else
        super
      end
    end

    # No need to save the board itself.  Board#yaml_initialize will reset
    # itself.

    def to_yaml_properties # :nodoc:
      ['@coords']
    end
  end

  # Namespace for plugins.

  module Plugins
    def self.all
      @all ||= {}
    end

    def self.included(base)
      plugin_name = base.name.split(/::/).last.
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase.to_sym

      all[plugin_name] = base

      base.class_eval { define_singleton_method(:plugin_name) { plugin_name } }
    end
  end

  # Find Board plugins (Modules).  Given a string like
  # "Board::Plugins::Frontier" it will return that module.  Given a string
  # like "frontier" or the symbol :frontier, it will look in the Board::Plugins
  # namespace for a module named Frontier.  If the string where to contain
  # underscores it would be translated from snake case to camel case.

  def self.find_plugin(s)
    return s  if s.nil? || s.kind_of?(Module)

    Plugins.all[s.to_sym]
  end

  # When loading a YAML-ized Board, be sure to re-extend plugins.

  def yaml_initialize(tag, vals) # :nodoc:
    vals.each do |iv, v|
      instance_variable_set("@#{iv}", v)
      v.each { |p| extend Board.find_plugin(p) } if iv == 'plugins'
      v.instance_variable_set('@board', self) if iv == 'coords'
    end
  end

  # Board.new pretends to be private.  In an earlier revision it was
  # private, but that was causing odd errors with Class#prototype's use of
  # alias (stemming from the fact that Board has subclasses who's new methods
  # are not private) when run under ruby 1.9.

  def self.new(*args) # :nodoc:
    if self == Board
      raise NoMethodError, "undefined method `new' for Board:Class"
    end

    super
  end

  private

  # Extend self with the given plugin and any dependencies (that haven't
  # already been loaded).

  def plugin(p)
    if p = self.class.find_plugin(p)
      return if @plugins.include?(p.plugin_name)

      @plugins << p.plugin_name
      extend p

      if p.respond_to?(:dependencies)
        p.dependencies.each do |dp|
          plugin(dp)
        end
      end

    end
  end

  private :ci

end
