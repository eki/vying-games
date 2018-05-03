

# frozen_string_literal: true

class Game

  def self.fetch(id)
    r = Vying::Server.get('/api/game', game_id: id)

    r && r['game']
  end

end
