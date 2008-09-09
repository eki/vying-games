# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Adds the #will_flip? and #flip methods to Board.  These methods can be used
# for implementing Othello and like games.
#
# This plugin depends on the Frontier plugin.

module Board::Plugins::CustodialFlip

  def self.dependencies
    [:frontier]
  end

end

