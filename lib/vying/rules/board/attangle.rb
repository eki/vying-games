# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Attangle
#
# For detailed rules see:  http://vying.org/games/attangle
# or the official Attangle site: http://attangle.com

Rules.create( 'Attangle' ) do
  name     'Attangle'
  version  '0.1.0'

  players :white, :black
  option :board_size, :default => 4, :values => [3, 4, 5]

  score_determines_outcome

  cache :moves

  position do
    attr_reader :board, :stocks, :triples

    def init
      @board = Board.hexagon( :length => @options[:board_size], :plugins => [:stacking] )
      @stocks = { :white => [9, 18, 30][@options[:board_size] - 3], :black => [9, 18, 30][@options[:board_size] - 3] }
      @triples = ( [1, 3, 5][@options[:board_size] - 3] ).freeze
    end

    def moves( player=nil )
      return [] if player.nil?

      all = []

      # Every empty cell (except the center) is a valid move
      all += board.unoccupied - [ Coord.new( board.length - 1, board.length - 1 ) ] if stocks[player] > 0

      # All possible capture moves
      board.occupied.each do |allc|
        if !allc.first.nil? && allc.first.first == opponent( player )

          allc.last.each do |c|
            # Collect all possible attacking pieces
            attackers = []
            board.directions.each do |d|
              scanc = c
              while scanc = board.coords.next( scanc, d )
                if !board[scanc].nil? && board[scanc].first == player
                  attackers << [ scanc, board[scanc].length ]
                  break
                end
              end
            end

            # Construct all possible moves
            attackers.each do |a1|
              attackers.each do |a2|
                if a1 != a2 && a1.last + a2.last + board[c].length <= 4
                  all << "#{a1.first}#{a2.first}#{c}"
                end
              end
            end

          end
        end
      end
      all
    end

    def apply!( move )
      coords = move.to_coords
      if coords.length == 1
        board[coords.first] = [turn]
        stocks[turn] -= 1
      else
        if board[coords.first].length == 1
          board[coords.last] = board[coords[1]] + board[coords.last]
        else
          board[coords.last] = board[coords.first] + board[coords.last]
        end
        board[coords.last].flatten!
        board[coords.first] = board[coords[1]] = nil
        stocks[turn] += 1
      end
      rotate_turn
      self
    end

    def final?
      players.any? { |p| score( p ) >= triples || moves( p ).empty? }
    end

    def score( player )
      count = 0
      board.occupied.each_pair do |c, p|
        next if c.nil?
        count += p.length if c.first == player && c.length == 3
      end
      count
    end

    def hash
      [board, turn].hash
    end

  end
end

module Board::Plugins::Stacking

  # Automatically growing board for different stack heights
  def to_s
    off = height >= 10 ? 2 : 1
    w = width
    sp = @cells.compact.max { |a,b| a.length <=> b.length }.length
    letters = "#{' ' * off}#{('a'...(?a+w).chr).collect { |l| ' ' + l + ' ' * sp }}#{' ' * off}\n"

    s = letters
    height.times do |y|
      s += sprintf( "%*d", off, y+1 )
      s += row(y).inject( '' ) do |rs,p|
        stack = p.collect { |x| x.to_s[0..0] }.join if p
        rs + (p ? " #{stack}#{'_' * (sp - stack.length)} " : " #{'_' * sp} ")
      end
      s += sprintf( "%*d\n", -off, y+1 )
    end
    s + letters
  end

end

