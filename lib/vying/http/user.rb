
class User

  def self.fetch( id )
    r = Vying::Server.get( "/api/user", :user_id => id )

    r && r['user']
  end

  def self.myself
    r = Vying::Server.get( "/api/myself" )

    r && r['user']
  end

  def profile
    return nil       if id.nil?
    return @profile  if @profile

    r = Vying::Server.get( "/api/profile", :user_id => id )

    @profile = r && r['profile']
  end

  def records
    return nil       if id.nil?
    return @records  if @records

    r = Vying::Server.get( "/api/records", :user_id => id )

    @records = r && r['records']
  end

  def games( params={} )
    return nil  if id.nil?

    params[:user_id] = id

    r = Vying::Server.get( "/api/games", params )
  end

  def cycle
    return nil  if id.nil?

    r = Vying::Server.get( "/api/cycle", :user_id => id )

    if p = (r && r['position'])
      p.instance_variable_set( "@game_id",        r['game_id'] )
      p.instance_variable_set( "@sequence",       r['sequence'] )
      p.instance_variable_set( "@sequence_index", r['n'] )
      p.instance_variable_set( "@you",            r['you'] )
    end

    p
  end

end

