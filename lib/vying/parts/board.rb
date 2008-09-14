
require 'vying/parts/board/coord'
require 'vying/parts/board/coords'

require 'vying/parts/board/board'
require 'vying/parts/board/shapes/hexagon'
require 'vying/parts/board/shapes/infinite'
require 'vying/parts/board/shapes/rect'
require 'vying/parts/board/shapes/rhombus'
require 'vying/parts/board/shapes/square'
require 'vying/parts/board/shapes/triangle'

require 'vying/parts/board/plugins/custodial_flip'
require 'vying/parts/board/plugins/in_a_row'
require 'vying/parts/board/plugins/frontier'
require 'vying/parts/board/plugins/stacking'

require 'vying/parts/board/plugins/amazons'

# Extensions are loaded after Ruby code so they can override whatever they
# like by reopening the classes.  Vying keeps track of which methods are
# overridden.  See Vying.defined_in_extension.

Vying.load_extension :java, 'vying_board_ext'
Vying.load_extension :c,    'vying/c/parts/board/boardext'

