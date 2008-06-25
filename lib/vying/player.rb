# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

#  Player is only used by Game to represent the combination of a player
#  (the Symbols used by Rules), and a User.

class Player
  attr_reader :name, :game
  attr_accessor :user

  def initialize( name, game, user=nil )
    @name, @game, @user = name, game, user
  end

  def has_moves?
    game.has_moves?( name )
  end

  def winner?
    game.winner?( name )
  end

  def loser?
    game.loser?( name )
  end

  def score
    game.score( name )
  end

  def <<( move )
    game.append( move, name )
    self
  end

  def username
    user && user.username
  end
end

