
begin
  require 'vying/parts/board/boardext'
  Vying::UsingBoardExt = true
rescue LoadError, SyntaxError
  require 'vying/parts/board/ruby'
  Vying::UsingBoardExt = false
end

require 'vying/parts/board/coord'
require 'vying/parts/board/coords'
require 'vying/parts/board/board'

require 'vying/parts/board/plugins/custodial_flip'
require 'vying/parts/board/plugins/in_a_row'
require 'vying/parts/board/plugins/frontier'

require 'vying/parts/board/plugins/amazons'

