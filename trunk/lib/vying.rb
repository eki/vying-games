# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/board/board'
require 'vying/board/amazons'
require 'vying/board/othello'
require 'vying/board/connect6'
require 'vying/board/mancala'

require 'vying/rules'
require 'vying/game'
require 'vying/ai/search'
require 'vying/ai/bot'

require 'yaml'

Rules.require_all
Bot.require_all

# Container for constants related to the vying library

module Vying
  
  # Returns the version of this vying codebase.

  def self.version
    v = const_defined?( :VERSION ) ? VERSION : "svn trunk"
    "vying #{v}"
  end
end

