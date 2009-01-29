# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Havannah
#
# For detailed rules see:  http://vying.org/games/havannah

Rules.create( "Havannah" ) do
  name    "Havannah"
  version "0.0.1"

  pie_rule

  players :blue, :red

  cache :init, :moves

  position do
    attr_reader :board, :groups
    ignore :groups

    def init
      @board = Board.hexagon( 10, :plugins => [:connection] )
    end

    def moves
      return []  if final?

      board.unoccupied
    end

    def apply!( move )
      board[move] = turn
      rotate_turn
      self
    end

    def final?
      board.unoccupied.empty? || players.any? { |p| winner?( p ) }
    end

    def winner?( player )
      (g = board.groups[player].last) && 
      (bridge?( g ) || fork?( g ) || ring?( g ))
    end

    def draw?
      board.unoccupied.empty? && players.all? { |p| ! winner?( p ) }
    end

    private

    # Is the given coord in a corner?

    def corner?( c )
      s1, s12 = board.length - 1, (board.length - 1) * 2

      (c.x == 0  && c.y == 0)   || (c.x == 0   && c.y == s1) ||
      (c.x == s1 && c.y == 0)   || (c.x == s12 && c.y == s1) ||
      (c.x == s1 && c.y == s12) || (c.x == s12 && c.y == s12)
    end

    # Does the given group connect (any) 3 sides?  Corners are not considered
    # a part of the sides for a fork.

    def fork?( group )
      s1, s12 = board.length - 1, (board.length - 1) * 2

      count = 0

      count += 1 if group.coords.any? { |c| c.x == 0   && ! corner?( c ) }
      count += 1 if group.coords.any? { |c| c.y == 0   && ! corner?( c ) }
      count += 1 if group.coords.any? { |c| c.x == s12 && ! corner?( c ) }

      return true if count == 3

      count += 1 if group.coords.any? { |c| c.y == s12 && ! corner?( c ) }

      return true if count == 3

      count += 1 if group.coords.any? { |c| c.x - c.y == s1 && ! corner?( c ) }

      return true if count == 3

      count += 1 if group.coords.any? { |c| c.y - c.x == s1 && ! corner?( c ) }

      count == 3
    end

    # Does the group represent a bridge?  It must connect two corners.

    def bridge?( group )
      group.coords.select { |c| corner?( c ) }.length == 2
    end

    # Does this group represent a ring?  In Havannah a ring is a set of coords
    # that surround at least one cell.  The surrounded cell maybe empty or
    # occupied with a piece of any color.

    def ring?( group )
      return false if group.coords.length < 6  # minimum ring needs 6 cells

      c = group.coords.last  # HACK ALERT:  Assumes the last coord in the
                             # group is the last added, also assumes all
                             # other coords in the group have been checked!

      ns = board.coords.neighbors( c )
      ms = ns.select { |nc| group.coords.include?( nc ) }
      return false  unless ms.length >= 2  # can't form a ring without
                                           # connecting at least two cells

      # check for a "blob" -- a 7-cell hexagon pattern

      (ms + [c]).each do |bc|
        bns = board.coords.neighbors( bc )
        if bns.length == 6 && bns.all? { |bnc| group.coords.include?( bnc ) }
          return true
        end
      end

      # check for rings with holes
      #
      # Iterate over empty neighbors and their neighbors, marking them as we
      # go.  If we can find an edge, the empty neighbor is not contained in
      # a ring.  Note, the "empty" neighbors are simply not a part of this
      # group.  That means they may be empty or owned by an opponent.
      #
      # Break and return immediately if a ring is found.
      #
      # On subsequent passes it's enough to find a previously marked coord,
      # because we know it must be connected to an edge.
      #
      # This doesn't find blob patterns, hence the previous check.

      s1, s12 = board.length - 1, (board.length - 1) * 2

      es = ns - ms

      marked = []
      es.each_with_index do |sc, i|
        check, found_marked, found = [sc], false, true

        until check.empty?
          nc = check.pop
          marked << nc

          if nc == sc || ! group.coords.include?( nc )
            board.coords.neighbors( nc ).each do |nnc|
              if i > 0 && marked.include?( nnc )
                found_marked = true
                break
              end

              unless marked.include?( nnc ) || group.coords.include?( nnc )
                check << nnc
              end
            end
          end

          if found_marked       ||
             nc.x == 0          || nc.y == 0   || 
             nc.x == s12        || nc.y == s12 ||
             nc.x - nc.y == s12 || nc.y - nc.x == s12

            found = false
            break
          end
        end

        return true  if found
      end

      false
    end

  end

end

