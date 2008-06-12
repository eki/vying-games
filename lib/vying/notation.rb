
class Notation

  attr_reader :game

  def initialize( game=nil )
    @game = game
  end

  def to_move( s, player=nil )
    s
  end

  def translate( move, player=nil )
    move
  end

  def sequence( game=nil )
    g = game || @game

    return [] unless g

    s = []
    g.history.each do |move, player, position|
      s << translate( move, player )
    end

    s
  end

  # Scans the RUBYLIB (unless overridden via path), for notation subclasses and
  # requires them.  Looks for files that match:
  #
  #   <Dir from path>/**/notations/*.rb
  #

  def Notation.require_all( path=$: )
    required = []
    path.each do |d|
      Dir.glob( "#{d}/**/notations/*.rb" ) do |f|
        f =~ /(.*)\/notations\/([\w\d]+\.rb)$/
        if ! required.include?( $2 ) && !f["_test"]
          required << $2
          require "#{f}"
        end
      end
    end
  end

  @@notation_list = []

  # When a subclass extends Notation, it is added to @@notation_list.

  def self.inherited( child )
    @@notation_list << child
  end

  # Get a list of all Notation subclasses.

  def Notation.list
    @@notation_list
  end

end

