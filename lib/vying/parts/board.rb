
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

require 'vying/parts/board/plugins/frontier'

require 'vying/parts/board/amazons'
require 'vying/parts/board/connect6'
require 'vying/parts/board/othello'

