# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/games'

module Board::Plugins::Connection
  include Board::Plugins

  class Group
    attr_reader :coords

    def initialize(board, coords=[])
      @board, @coords = board, coords
    end

    def |(other)
      Group.new(@board, coords | other.coords)
    end

    def <<(c)
      coords << c
    end

    def include?(c)
      coords.include?(c)
    end

    def ==(other)
      other.respond_to?(:coords) && coords == other.coords
    end

    def inspect
      "#<Group coords: #{coords.inspect}>"
    end
  end

  attr_reader :groups

  def init_plugin
    super
    @groups = Hash.new([])
  end

  def initialize_copy(original)
    super
    @groups = Hash.new([])
    original_groups = original.instance_variable_get('@groups')
    original_groups.each do |k, v|
      @groups[k] = v.map { |g| Group.new(self, g.coords.dup) }
    end
  end

  def fill(p)
    super
    groups.clear

    if p
      groups[p] = Group.new(self, coords.to_a.dup)
    end
  end

  # The #update_groups method is called automatically after each set call.

  def after_set(x, y, p)
    super
    update_groups(x, y, p)
  end

  # Update #groups after a piece has been placed or removed.  There is no
  # need to call this manually.

  def update_groups(x, y, p)
    c = Coord[x, y]

    oldp, oldg = nil, nil

    groups.each do |gp, gs|
      oldg = gs.find { |g| g.include?(c) }

      if oldg
        oldp = gp
        break
      end
    end

    return if oldp == p # No change!

    # Split up the old group if necessary

    if oldp
      oldg.coords.delete(c)

      ncs = coords.neighbors(c).select { |nc| oldg.include?(nc) }

      if ncs.empty? || !coords.connected?(ncs)
        groups[oldp].delete(oldg) # The group has been split or emptied

        new_groups = []
        ncs.each do |nc|
          unless new_groups.any? { |g| g.include?(nc) }
            new_groups << build_group(nc)
          end
        end

        groups[oldp] += new_groups
      end
    end

    # Add to an existing group / Join multiple existing groups

    if p
      new_groups = []
      coords.neighbors(c).each do |n|
        groups[p].delete_if do |g|
          if g.include?(n)
            g << c
            new_groups << g
          end
        end
      end

      if new_groups.empty?
        groups[p] = [] if groups[p].empty?
        groups[p] << Group.new(self, [c])
      else
        g = Group.new(self)
        groups[p] << new_groups.inject(g) { |m, a| m | a }
      end
    end
  end

  private

  def build_group(c)
    p, cs, check = self[c], [], [c]

    while c = check.pop
      cs << c

      coords.neighbors(c).each do |nc|
        check << nc  unless cs.include?(nc) || self[nc] != p
      end
    end

    Group.new(self, cs)
  end

end
