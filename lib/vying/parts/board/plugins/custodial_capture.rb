# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Adds the #will_flip? and #flip methods to Board.  These methods can be used
# for implementing Othello and like games.

module Board::Plugins::CustodialCapture

  # Place the given piece p at Coord c and make any valid custodial captures
  # as a side effect.  To limit the captures to a certain number of pieces,
  # provide a range.  To make unlimited captures the range can be omitted.
  #
  # For example:
  #
  #   b.custodial_capture( Coord[:a1], :x, 3..4 )
  #
  # With the given lines (where :a1 is represented with a '.'):
  #
  #     .oox    => no capture
  #     .ooox   => capture
  #     .oooox  => capture
  #     .ooooox => no capture
  #
  # This method returns an array containing the coords of pieces that were
  # successfully captured.  It is possible that no pieces will be capture,
  # in which case p is still placed at coord c.

  def custodial_capture(c, p, range=nil)
    custodial(c, p, nil, range)
  end

  # Will playing piece p at coord c result in a custodial capture?  The
  # optional range can be used to restrict the capture test.

  def custodial_capture?(c, p, range=nil)
    a = directions.zip(coords.neighbors_nil(c))
    a.each do |d, nc|
      next if self[nc].nil? || self[nc] == p

      bt = [nc]
      while bt << coords.next(bt.last, d)
        break if self[bt.last].nil?
        break if range && bt.length - 1 < range.first && self[bt.last] == p
        next  if range && bt.length - 1 < range.first
        break if range && bt.length - 1 > range.last

        return true if self[bt.last] == p
      end
    end

    false
  end

  # Does the heavy lifting for custodial actions.  Takes the coord to play,
  # the piece to place, what to replace captured pieces with, and the range
  # to effect.

  def custodial(c, p, replacement=nil, range=nil)
    self[c] = p

    cap = []
    a = directions.zip(coords.neighbors_nil(c))
    a.each do |d, nc|
      next if self[nc].nil? || self[nc] == p

      bt = [nc]
      while bt << coords.next(bt.last, d)
        break if self[bt.last].nil?
        break if range && bt.length - 1 < range.first && self[bt.last] == p
        next  if range && bt.length - 1 < range.first
        break if range && bt.length - 1 > range.last

        next unless self[bt.last] == p
        bt.pop
        cap += bt
        break
      end
    end

    cap.each do |cc|
      self[cc] = replacement
    end

    cap
  end

  private :custodial

end
