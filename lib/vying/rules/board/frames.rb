# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Vying.rules( "Frames" ) do
  name    "Frames"
  version "0.4.0"

  players :black, :white

  highest_score_determines_winner

  cache :moves

  position do
    attr_reader :board, :sealed, :points, :frame

    def init
      @board = Board.square( 19 )
      @sealed = {}
      @points = { :black => 0, :white => 0 }
      @frame = []
    end

    def has_moves
      final? ? [] : players.select { |p| ! sealed[p] }
    end

    def moves( player )
      return [] if final?

      board.unoccupied
    end

    def apply!( move, player )
      sealed[player] = Coord[move]

      if sealed[:black] && sealed[:white]
        if sealed[:black] == sealed[:white]
          board[move] = :neutral
          frame.clear
        else
          fb = sealed[:black]
          fw = sealed[:white]

          board[fb], board[fw] = :black, :white

          count = { :black => 0, :white => 0 }
          max_x, min_x = [fb.x, fw.x].max, [fb.x, fw.x].min
          max_y, min_y = [fb.y, fw.y].max, [fb.y, fw.y].min
      
          if max_x > min_x + 1 && max_y > min_y +1 
            board.coords.each do |c|
              if (board[c] == :black || board[c] == :white) &&
                 (min_x < c.x && c.x < max_x && min_y < c.y && c.y < max_y)
                count[board[c]] += 1
              end
            end
        
            points[:black] += 1 if count[:black] > count[:white]
            points[:white] += 1 if count[:white] > count[:black]

            frame.replace [fb, fw]
          else
            frame.clear
          end
        end

        sealed.clear
      end

      self
    end

    def final?
      board.unoccupied.empty? || players.any? { |p| score( p ) >= 10 }
    end

    def score( player )
      points[player]
    end

    def censor( player )
      position = super( player )

      players.each do |p|
        if p != player && ! position.sealed[p].nil?
          position.sealed[p] = :hidden
        end
      end

      position
    end
  end

end

