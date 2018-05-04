# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Adds the #custodial_flip? and #custodial_flip methods to Board.  These
# methods can be used for implementing Othello and like games.

module Board::Plugins::CustodialFlip
  include Board::Plugins

  def self.dependencies
    [:custodial_capture]
  end

  # Place the given piece p at Coord c and make any valid custodial flips
  # as a side effect.  To limit the flips to a certain number of pieces,
  # provide a range.  To make unlimited flips the range can be omitted.
  #
  # For example:
  #
  #   b.custodial_flip( Coord[:a1], :x, 3..4 )
  #
  # With the given lines (where :a1 is represented with a '.'):
  #
  #     .oox    => no flip
  #     .ooox   => flip
  #     .oooox  => flip
  #     .ooooox => no flip
  #
  # This method returns an array containing the coords of pieces that were
  # successfully flipped.  It is possible that no pieces will be flipped,
  # in which case p is still placed at coord c.

  def custodial_flip(c, p, range=nil)
    custodial(c, p, p, range)
  end

  # Will pieces be flipped if piece p is placed at coord c?  Optional range
  # limites the number of pieces that may be flipped.

  def custodial_flip?(c, p, range=nil)
    custodial_capture?(c, p, range)
  end

end
