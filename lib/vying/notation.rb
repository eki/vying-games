# frozen_string_literal: true

# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying

  #  Notation is used to translate from a Rules underlying move notation into
  #  something more commonly used.  For example, many games use Coord-like
  #  strings for moves because they work well with Board.  So, to move a piece
  #  from (0,0) to (1,0) we would commonly encode the move as "a1b1".  However,
  #  this Chess-like notation is sometimes not prefered for a game.  In checkers
  #  games, the squares are usually numbered.  So, we'd prefer to present
  #  moves as "9-14", for example.  Notation provides a convenient mapping.
  #
  #  To use a notation, declare it in the Rules definition:
  #
  #    Rules.create( "AmericanCheckers" ) do
  #      name    "American Checkers"
  #      notation :checkers_notation
  #
  #  Game then adapts the notation automatically.  For example:
  #
  #    >> g = Game.new AmericanCheckers
  #    >> g.moves
  #    => ["b3c4", "b3a4", "d3e4", "d3c4", "f3g4", "f3e4", "h3g4"]
  #    >> g.notation.moves
  #    => ["9-14", "9-13", "10-15", "10-14", "11-16", "11-15", "12-16"]
  #
  #  Notation also allows playing moves encoded in the notatioin:
  #
  #    >> g.notation << "9-14"
  #    >> g.history.moves.last
  #    => b3c4:red
  #
  #  You can also have the sequence of moves played translated:
  #
  #    >> g.sequence
  #    => ["b3c4"]
  #    >> g.notation.sequence
  #    => ["9-14"]
  #

  class Notation

    attr_reader :game

    # The Game to provide notation translations for.

    def initialize(game)
      @game = game
    end

    # Translate the given String from this notation into an underlying move.

    def to_move(s)
      s
    end

    # Translate the underlying move into this notation.

    def translate(move, _player)
      move
    end

    # Translate Game#sequence.

    def sequence
      s = []
      game.history.moves.each do |move|
        s << translate(move, move.by).to_s
      end

      s
    end

    # Translate Game#moves

    def moves(player=nil)
      ps = player ? [player] : game.has_moves
      ms = []

      ps.each { |p| game.moves(p).each { |m| ms << translate(m, p) } }

      ms
    end

    # Translate the given move from this notation and play it via Game#append.

    def append(move, player=nil)
      game.append(to_move(move), player)
    end

    # Translate the given moves from this notation and play them via
    # Game#append_list.

    def append_list(moves)
      game.append_list(moves.map { |m| to_move(m) })
    end

    # Translate the given move(s) from this notation and play them via Game#<<.

    def <<(moves)
      if moves.kind_of? Enumerable
        append_list(moves)
      else
        append(moves)
      end
    end

    # Scans the RUBYLIB (unless overridden via path), for notation subclasses
    # and requires them.  Looks for files that match:
    #
    #   <Dir from path>/**/notations/*.rb
    #

    def self.require_all(path=$LOAD_PATH)
      required = []
      path.each do |d|
        Dir.glob("#{d}/**/notations/*.rb") do |f|
          f =~ /(.*)\/notations\/([\w\d]+\.rb)$/
          if !required.include?(Regexp.last_match(2)) && !f['_test']
            required << Regexp.last_match(2)
            require f.to_s
          end
        end
      end
    end

    @@notation_list = []

    # When a subclass extends Notation, it is added to @@notation_list.

    def self.inherited(child)
      @@notation_list << child
    end

    # Get a list of all Notation subclasses.

    def self.list
      @@notation_list
    end

    # Find a specific Notation by name

    def self.find(name)
      list.find { |n| n.notation_name == name }
    end

  end
end
