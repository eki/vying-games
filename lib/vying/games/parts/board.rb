# frozen_string_literal: true

require 'vying/games/parts/board/pieces/counter'

require 'vying/games/parts/board/coord'
require 'vying/games/parts/board/coords'

require 'vying/games/parts/board/board'
require 'vying/games/parts/board/shapes/hexagon'
require 'vying/games/parts/board/shapes/infinite'
require 'vying/games/parts/board/shapes/rect'
require 'vying/games/parts/board/shapes/rhombus'
require 'vying/games/parts/board/shapes/square'
require 'vying/games/parts/board/shapes/triangle'

require 'vying/games/parts/board/plugins/connection'
require 'vying/games/parts/board/plugins/custodial_capture'
require 'vying/games/parts/board/plugins/custodial_flip'
require 'vying/games/parts/board/plugins/in_a_row'
require 'vying/games/parts/board/plugins/frontier'
require 'vying/games/parts/board/plugins/stacking'

require 'vying/games/parts/board/plugins/amazons'

# Extensions are loaded after Ruby code so they can override whatever they
# like by reopening the classes.  Vying::Games keeps track of which methods are
# overridden.  See Vying::Games.defined_in_extension.

Vying::Games.load_extension :c, 'vying/games/c/parts/board/boardext'
