

class Position 

  def self.fetch( game_id, n=nil )
    params = { :game_id => game_id }
    params[:n] = n  if n

    r = Vying::Server.get( "/api/position", params )

    r && r['position']
  end

end

