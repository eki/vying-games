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

