This is a really old library that's only very infrequently maintained. It *was*
the core of a game server (Vying Games) that was shutdown about a million years
ago.

Because this library is so old, it doesn't always follow what are generally
considered Ruby best practices. Buyer beware!

---

# Vying Games

Vying Games is a library for multi-player, turn-based, strategy games. The
goal is to make it easy to implement a large number of games very quickly,
with only a small amount of code. This includes the rules (or game logic) and
AI, but does not extend to user interface code (though there is a small,
primitive command-line program for playing games).

Some of vying's features are:

* Support for a wide range of game elements
  * Games with random starting positions
  * Games with random events (dice rolls, for example)
  * While turn-based, games may feature simultaneous turns (or sealed moves) 
* Includes support for board games and card games (though the card game
  support is a little primitive still)
* Most "rules" can be implemented approximately 100 lines of Ruby code
* Fairly simple bot interface can make AI programming fairly simple (this
  needs improvement) 


## The Games

Implements the logic for:

  * Abande
  * Accasta
  * Amazons
  * American Checkers
  * Ataxx
  * Attangle
  * Breakthrough
  * Cephalopod
  * Connect Four
  * Connect6
  * Dodgem
  * Dots and Boxes
  * Footsteps
  * Frames
  * Havannah
  * Hearts
  * Hex
  * Hexplode
  * Hexthello
  * Hexxagon
  * Kalah
  * Keryo-Pente
  * Lines of Action
  * Misere Dots and Boxes
  * Nine Men's Morris
  * Ordo
  * Othello
  * Oware
  * Pah-Tum
  * Pente
  * Phutball
  * Pig
  * Spangles
  * Three Musketeers
  * Tic Tac Toe
  * Y
  * YINSH
  * Yavalath

## Installation

Vying Games is **NOT** currently available as a gem. Grab the code if you'd
like to try it:

```
  git clone git@github.com:eki/vying-games.git
```

This gem has a native C extension to provide better performance (in some
areas).  There are Ruby equivalents for all the C code, meaning the extension
is not necessary.  It's loaded dynamically if present. Use `rake compile` to
build the extension.

## Command-Line Interface

This package includes a small command-line application called 'vg' that can
be invoked in the following ways.  To get more help on any of these commands
type:

```
  vg --help
```

To play a game:

```
  vg play --rules Breakthrough --player white=Human --player black=RandomBot
```

To benchmark a game:

```
  vg bench --rules Breakthrough
```

To check the branching factor of a game:

```
  vg branch --rules Breakthrough
```

To get info about a game:

```
  vg info --rules Breakthrough
```

## Example Code

At the heart of the library are the Rules for a game.  For example:

```
  Rules.create( "TicTacToe" ) do
    name    "Tic Tac Toe"
    version "1.0.0"
  end
```

The above is a start at defining the Rules for Tic Tac Toe.  The Rules contain
largely static information about the game, such as the name of the game or
the player names.  Below, we start to define what a Position in a game of
Tic Tac Toe would look like.  A Game will be made up (in part) of a series
of Position, each position is created by changing the previous position by
playing a move.

```
  Rules.create( "TicTacToe" ) do
    name    "Tic Tac Toe"
    version "1.0.0"

    players :x, :o

    position do
      attr_reader :board

      def init
        @board = Board.new( 3, 3 )
      end
    end
  end
```

In the above example the players (:x, :o) were defined.  The player symbols
declared in the order that the players take turns.  In this case, :x will go
first, and the :o.  

In addition, the position is defined to include a 3x3 board.  It can be
accessed through a method 'board', like so:

```
  position = TicTacToe.new
  puts position.board
```

If we were to continue this example, we'd need to define a #moves method to
return tokens (Strings) representing each move.  In Tic Tac Toe, we'd probably 
return the coordinates representing where the player would place an X or O on 
the board.  We'd also define an #apply! method which would take a move token 
and alter the position state.

Finally (no pun intended), we'd define a #final? method that would return true 
if the position is final (the game is over).  We'd also define #winner?, 
#loser?, and #draw? methods.

There are more methods that can be defined depending on the game being
implemented but those are the basics at the core of every game.

Once some rules have been defined, we can play around with them like so:

```
  g = Game.new TicTacToe
```

A Game represents an entire tree of positions.  

```
  g.moves                  # Returns an array of possible moves
  g << g.moves.first       # Make the first move

  g.turn                   # Who's turn is it?

  g.board                  # Game passes calls through to the underlying
                           # (last) position, this is the equivalent of

  g.history.last.board
  g.history[3].board       # History can be used like an array to look back
                           # at any position

  g.move?( "a1" )          # Is "a1" a valid move?
  g.move?( "a1", :x )      # Is "a1" a valid move for :x?

  g.has_moves              # Returns a list of all the players who can move.
                           # Some games allow simultaneous moves, so checking
                           # #has_moves is safer than using #turn

  g.final?                 # Is the game over?
  g.winner?( :x )          # Did :x win the game?
  g.draw?                  # Is the game a draw?
  
  if g.has_score?
    g.score( :x )          # If the game has a score, what was :x's score?
  end

  # Setup a random game..

  g = Game.new TicTacToe
  g[:x] = RandomBot.new
  g[:o] = RandomBot.new
 
  g.step   # Play a single move (Game asks the appropriate Bot for it's move) 
  g.play   # Play out the entire game.
```
