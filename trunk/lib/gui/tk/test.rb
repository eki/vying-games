require 'tk'
require 'game'

root = TkRoot.new do
  title "Vying Board"
end

canvas = TkCanvas.new( root ) do
  pack
  width 32*8+2
  height 32*8+2
end

black = TkPhotoImage.new { file 'black32x32.gif' }
white = TkPhotoImage.new { file 'white32x32.gif' }

g = Game.new( Othello )
while ops = g.ops
  g << ops[rand(ops.length)]
end

b = g.board
b.coords.each do |c|
  if b[c] != nil
    img = b[c] == Piece.black ? black : white
    TkcImage.new( canvas, c.x*32+17, c.y*32+17, 'image' => img )
  end
end

Tk.mainloop

