# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Adds the frontier method to Board and keeps it updated automatically.
# Frontier is defined as a list of Coord's for empty cells that neighbor
# occupied cells.  Tracking frontier can be useful, for example, if all
# a game's valid moves are found on the frontier.

module Board::Plugins::Frontier
  include Board::Plugins

  attr_reader :frontier

  # Initialize the Frontier plugin.

  def init_plugin
    super
    @frontier = []
  end

  # Make a deep copy of the data associated with the Frontier plugin.

  def initialize_copy(original)
    super
    @frontier = original.frontier.dup
  end

  # Filling the board will result in no frontier (either the board is empty,
  # or completely filled).

  def fill(p)
    super
    @frontier.clear
  end

  # Update the frontier list after setting a piece.

  def after_set(x, y, p)
    super

    c = Coord[x, y]

    return unless coords.include?(c)

    if p.nil?
      coords.neighbors(c).each do |nc|
        if self[nc]
          update_frontier(nc)
        else
          unless coords.neighbors(nc).any? { |nnc| self[nnc] }
            frontier.delete(nc)
          end
        end
      end
    else
      update_frontier(c)
    end
  end

  def update_frontier(c)
    directions(c).each do |d|
      nc = coords.next(c, d)

      if !nc.nil? && self[nc].nil?
        frontier << nc
      end
    end

    frontier.delete(c)
    frontier.uniq!
    frontier
  end
end
