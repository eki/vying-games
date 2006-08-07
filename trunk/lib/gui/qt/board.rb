require 'Qt'
require 'game'
require 'board/standard'

class Box
  attr_accessor :x, :y, :width, :height

  def initialize( x, y, width, height )
    @x, @y, @width, @height = x, y, width, height
  end
end

class QtPiece
  attr_accessor :piece, :canvas, :x, :y, :width, :height, :primitives, :box

  COLORS = ["White", "Black", "Red", "Blue"]

  def initialize( piece, box, canvas )
    @piece = piece
    @canvas = canvas
    @box = box
    @x, @y, @width, @height = box.x, box.y, box.width, box.height
    @primitives = get_primitives( piece )
  end

  def hide
    primitives.each { |prim| prim.setVisible( false ) }
  end

  def ==( p )
    return self.piece == p if p.kind_of?( Piece )
    self.equal?( p )
  end

  def get_primitives( piece )
    if piece.instance_of?( Fixnum ) || piece.instance_of?( Symbol )
      text = Qt::CanvasText.new( canvas )
      text.setColor( Qt::Color.new( "black" ) )
      text.setText( piece.to_s )
      text.setX( x+width/2 )
      text.setY( y+height/2 )
      text.setZ( 2 )
      text.show
      return [text]
    elsif COLORS.include?( piece.name )
      circle = Qt::CanvasEllipse.new( width, height, canvas )
      circle.setX( x+width/2 )
      circle.setY( y+height/2 )
      circle.setZ( 2 )
      circle.setBrush( Qt::Brush.new( Qt::Color.new( piece.name ) ) )
      circle.show
      return [circle]
    elsif piece.name == "Arrow"
      lines = []

      line = Qt::CanvasLine.new( canvas )
      line.setPoints( x+width/8, y+height/8, x+width/8*7, y+height/8*7 )
      line.setPen( Qt::Pen.new( Qt::Color.new( "black" ), 2 ) )
      line.setZ( 2 )
      line.show
      lines << line

      line = Qt::CanvasLine.new( canvas )
      line.setPoints( x+width/8*7, y+height/8*7, x+width/8*7, y+height/8*6 )
      line.setPen( Qt::Pen.new( Qt::Color.new( "black" ), 2 ) )
      line.setZ( 2 )
      line.show
      lines << line

      line = Qt::CanvasLine.new( canvas )
      line.setPoints( x+width/8*7, y+height/8*7, x+width/8*6, y+height/8*7 )
      line.setPen( Qt::Pen.new( Qt::Color.new( "black" ), 2 ) )
      line.setZ( 2 )
      line.show
      lines << line
      return lines
    elsif piece.name == "X"
      lines = []

      line = Qt::CanvasLine.new( canvas )
      line.setPoints( x+width/8*7, y+height/8*7, x+width/8, y+height/8 )
      line.setPen( Qt::Pen.new( Qt::Color.new( "black" ), 2 ) )
      line.setZ( 2 )
      line.show
      lines << line

      line = Qt::CanvasLine.new( canvas )
      line.setPoints( x+width/8, y+height/8*7, x+width/8*7, y+height/8 )
      line.setPen( Qt::Pen.new( Qt::Color.new( "black" ), 2 ) )
      line.setZ( 2 )
      line.show
      lines << line
      return lines
    elsif piece.name == "O"
      circle = Qt::CanvasEllipse.new( width, height, canvas )
      circle.setX( x+width/2 )
      circle.setY( y+height/2 )
      circle.setZ( 2 )
      circle.setBrush( Qt::Brush.new( Qt::Color.new( "black" ) ) )
      circle.show
      return [circle]
    end
    []
  end
end

class QtBoard < Qt::Widget

  attr_accessor :game, :cells, :canvas, :view, :cell_width, :cell_height,
                :press, :bots

  def initialize( game, bots, width, height, parent=nil )
    super( parent )

    @game = game
    @cells = {}

    @bots = bots

    @cell_width = width / game.board.coords.width
    @cell_height = height / game.board.coords.height

    @canvas = Qt::Canvas.new( width, height )
    @view = Qt::CanvasView.new( self )
    view.setCanvas( canvas )

    @layout = Qt::VBoxLayout.new( self )
    @layout.addWidget( @view )

    draw_rects
  end

  def []=( c, p )
    cells[c].hide unless cells[c].nil?
    cells[c] = p
  end

  def []( c )
    cells[c]
  end

  def draw_rects
    game.board.coords.each do |c|
      rect = Qt::CanvasRectangle.new( canvas )
      rect.setSize( cell_width, cell_height )
      rect.setX( c.x*cell_width )
      rect.setY( c.y*cell_height )
      rect.setZ( 1 )
      rect.setBrush( Qt::Brush.new( Qt::Color.new( "green" ) ) )
      rect.show
    end
  end

  def sweep
    game.board.coords.each do |c|
      if self[c] != game.board[c]
        box = Box.new( c.x*cell_width, c.y*cell_height,
                       cell_width, cell_height )
        p = game.board[c]
        self[c] = p.nil? ? p : QtPiece.new( p, box, canvas )
      end
    end
  end

  def mouseReleaseEvent( event )
    return nil if game.final?

    c = Coord[event.x/cell_width, event.y/cell_height]

    success = false

    op = "#{c}" == "#{press}" ? "#{c}" : "#{press}#{c}"

    bots.each_pair do |p,b| 
      success = b.try( op ) if b.kind_of?( HumanBot ) && p == game.turn.current
    end

    update if success
  end

  def timerEvent( timerEvent )
    unless (b = bots[game.turn]).kind_of?( HumanBot ) || game.final?
      bots[game.turn].select!
      update
    end
  end

  def mousePressEvent( event )
    @press = Coord[event.x/cell_width, event.y/cell_height]
  end

  def update
    sweep
    canvas.update
  end

end
