# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "KeryoPente" ) do
  name    "Keryo-Pente"
  version "1.0.0"

  players :white, :black

  cache :moves

  position do
    attr_reader :board, :captured

    def init
      @board = Connect6Board.new( 5 )
      @captured = { :black => 0, :white => 0 }
    end

    def moves
      final? ? [] : board.unoccupied
    end

    def apply!( move )
      c = Coord[move]
      board[c] = turn

      # Custodian capture
      cap = []
      directions = [:n,:s,:e,:w,:ne,:nw,:se,:sw]
      a = directions.zip( board.coords.neighbors_nil( c, directions ) )
      a.each do |d,nc|
        next if board[nc].nil? || board[nc] == board[c]

        bt = [nc]
        while (bt << board.coords.next( bt.last, d ))
          break if board[bt.last].nil?
          break if bt.length < 3 && board[bt.last] == board[c]
          break if bt.length > 4

          if (bt.length == 3 || bt.length == 4) && board[bt.last] == board[c]
            bt.each { |bc| cap << bc unless board[bc] == board[c] }
            break
          end
        end
      end

      cap.each do |cc|  
        board[cc] = nil
        captured[turn] += 1
      end

      rotate_turn
      self
    end

    def final?
      board.unoccupied.empty? || captured.any? { |p, t| t >= 15 } ||
      board.threats.any? { |t| t.degree == 0 }
    end

    def winner?( player )
      captured[player] >= 15 ||
      board.threats.any? { |t| t.degree == 0 && t.player == player }
    end

    def loser?( player )
      winner?( opponent( player ) )
    end

    def draw?
      board.unoccupied.empty? && ! captured.any? { |p, t| t >= 15 } &&
      ! board.threats.any? { |t| t.degree == 0 }
    end

    def score( player )
      captured[player]
    end

    def hash
      [board, captured, turn].hash
    end
  end

end

