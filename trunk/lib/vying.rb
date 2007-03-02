require 'vying/board/board'
require 'vying/board/othello'
require 'vying/board/connect6'

require 'vying/rules'
require 'vying/game'
require 'vying/ai/bot'

require 'yaml'
require 'vying/serialize/json'

Rules.require_all
Bot.require_all

