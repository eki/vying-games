# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Adds the #will_flip? and #flip methods to Board.  These methods can be used
# for implementing Othello and like games.

module Board::Plugins::CustodialFlip

  def will_flip?( c, bp )
    return false if !self[c].nil?

    a = directions.zip( coords.neighbors_nil( c ) )
    a.each do |d,nc|
      p = self[nc]
      next if p.nil? || p == bp

      i = nc
      while (i = coords.next( i, d ))
        p = self[i]
        return true if p == bp 
        break       if p.nil?
      end
    end

    false
  end

  def custodial_flip( c, bp )
    a = directions.zip( coords.neighbors_nil( c ) )
    a.each do |d,nc|
      p = self[nc]
      next if p.nil? || p == bp

      bt = [nc]
      while (bt << coords.next( bt.last, d ))
        p = self[bt.last]
        break if p.nil?

        if p == bp
          bt.each { |bc| self[bc] = bp }
          break
        end
      end
    end

    self[c] = bp
  end
end

