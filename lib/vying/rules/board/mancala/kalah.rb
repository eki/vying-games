# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Kalah" ) do
  name    "Kalah"
  version "2.0.0"
  notation :mancala_notation

  players :one, :two

  pie_rule

  highest_score_determines_winner

  option :seeds_per_cup, :default => 6, :values => [3,4,5,6]

  cache :init

  position do
    attr_reader :board, :scoring_pits, :annotation
    ignore :sides, :annotation

    def init
      @board = Board.rect( 6, 2, :fill => @options[:seeds_per_cup] )

      @annotation = Board.rect( 6, 2, :fill => "0" )

      @scoring_pits = { :one => 0, :two => 0 }
      @sides = { :one => ['a1', 'b1', 'c1', 'd1', 'e1', 'f1'],
                 :two => ['a2', 'b2', 'c2', 'd2', 'e2', 'f2'] }
    end

    def moves
      @sides[turn].select { |c| board[c] > 0 }
    end

    def apply!( move )
      # Reset annotation
      annotation.fill( "0" )

      h = move.x
      r = move.y

      # Sowing seeds

      seeds, board[move] = board[move], 0
      last = nil

      annotation[move] = "e"

      seeds.times do
        if r == 0 && h == 0
          r = 1
          h = -1
          if turn == :one
            scoring_pits[:one] += 1
            last = :one
            next
          end
        end

        if r == 1 && h == 5
          r = 0
          h = 6
          if turn == :two
            scoring_pits[:two] += 1
            last = :two
            next
          end
        end

        h -= 1 if r == 0 && h > 0
        h += 1 if r == 1 && h < 6
      
        board[h,r] += 1
        if annotation[h,r] == 'e'
          annotation[h,r] = 'E'
        else
          annotation[h,r] = (annotation[h,r].to_i + 1).to_s
        end

        last = Coord[h,r]
      end

      # Capturing

      opp_y = last.y == 1 ? 0 : 1
      if last.kind_of?( Coord ) && board[last] == 1 && board[last.x,opp_y] > 0
        if last.y == 0 && turn == :one ||
           last.y == 1 && turn == :two
          scoring_pits[turn] += board[last.x,1]
          scoring_pits[turn] += board[last.x,0]
          board[last.x,1] = 0
          board[last.x,0] = 0
          annotation[last.x,0] = "c" if annotation[last.x,0] == "0"
          annotation[last.x,1] = "c" if annotation[last.x,1] == "0"
          annotation[last.x,0] = "C" if annotation[last.x,0] =~ /[1-9E]/
          annotation[last.x,1] = "C" if annotation[last.x,1] =~ /[1-9E]/
        end
      end

      # Extra turn?
      
      rotate_turn if last != :one && last != :two

      # Clear remaining seeds if the game is over

      if final?
        players.each do |p|
          @sides[p].each do |c|
            scoring_pits[p] += board[c]
            board[c] = 0
            annotation[c] = "c" if annotation[c] == "0"
            annotation[c] = "C" if annotation[c] =~ /[1-9E]/
          end
        end
      end 

      self
    end

    def final?
      players.any? { |p| @sides[p].all? { |c| board[c] == 0 } }
    end

    def score( player )
      scoring_pits[player]
    end
  end

end

