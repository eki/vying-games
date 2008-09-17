class AttangleNotation < Notation
 
  def self.notation_name
    :attangle_notation
  end
 
  def to_move( s, player )
    if s =~ /(\w\d),?(\w\d)-?(\w\d)/
      conv( $1 ) + conv( $2 ) + conv( $3 )
    else
      conv( s )
    end
  end
 
  def translate( move, player )
    s = ''
    move.to_coords.each do |c|
      if c.x >= game.length
        s += (97 + c.x).chr + (c.y - (c.x - game.length)).to_s
      else
        s += c.to_s
      end
    end
    s =~ /(\w\d)(\w\d)(\w\d)/ ? "#{$1},#{$2}-#{$3}" : s
  end

  private

  def conv( c )
    if c.x >= game.length
      (97 + c.x).chr + (c.y + (c.x - game.length) + 2).to_s
    else
      c
    end
  end

end
