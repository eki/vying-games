
module Vying
  class Position 

    attr_reader :game_id, :sequence_index, :sequence, :you

    def self.fetch( game_id, n=nil )
      params = { :game_id => game_id }
      params[:n] = n  if n

      r = Vying::Server.get( "/api/position", params )

      if p = (r && r['position'])
        p.instance_variable_set( "@game_id",        r['game_id'] )
        p.instance_variable_set( "@sequence",       r['sequence'] )
        p.instance_variable_set( "@sequence_index", r['n'] )
        p.instance_variable_set( "@you",            r['you'] )
      end

      p
    end

    def submit_move( *moves )
      if game_id && sequence_index
        return false  if moves.empty?
        return false  if SpecialMove[moves.first] && moves.length > 1

        p = self
        moves.each do |m|
          return false  unless p.move?( m )
          p = p.apply( m )
        end

        r = Vying::Server.post( "/api/move", 
          :game_id => game_id, 
          :n => sequence_index,
          :moves => moves  )

        if p = (r && r['position'])
          p.instance_variable_set( "@game_id", r['game_id'] )
          p.instance_variable_set( "@sequence_index", r['n'] )
        end

        p
      end
    end

  end
end

Rules.list.each do |r| 
  r.position_class.class_eval do 
    ignore :game_id, :sequence_index, :sequence, :you
  end
end

