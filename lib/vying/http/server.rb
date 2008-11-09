

class Vying::Server
  attr_reader :host, :port, :session, :auth_token, :username

  def initialize( host, port, username )
    @host, @port, @username = host, port, username
    @logged_in = true
  end

  def login( password, remember=false )
    url = "http://#{host}:#{port}/api/login"

    response = Net::HTTP.post_form( URI.parse( url ),
      :username => username,
      :password => password,
      :remember => remember )

    if response.code == '200'
      update_cookies( response.get_fields( 'set-cookie' ) )

      @logged_in = true
    else
      @logged_in = false
    end
  end

  def logged_in?
    @logged_in
  end

  def update_cookies( cookies )
    h = {}
    cookies.each do |c|
      n, v = c.split( ";" ).first.split( "=" )
      h[n] = v
    end

    @session    = h['_session_id'] if h['_session_id'] != session
    @auth_token = h['auth_token']  if h['auth_token']  != auth_token
  end

  def get( path, params )
    unless params.empty?
      path += "?"
      path += params.map { |n,v| "#{n}=#{v}" }.join( "&" )
    end

    headers = {}

    if c = cookie
      headers['Cookie'] = c
    end

    http = Net::HTTP.new( host, port )
    response = http.get( path, headers )

    if response.code == "200"
      puts response.body
      YAML.load( response.body )
    else
      nil
    end
  end

  def cookie
    s = ""

    s += "_session_id=#{session};"    if session
    s += "auth_token=#{auth_token};"  if auth_token 
    
    s != "" ? s : nil
  end

  class << self
    attr_reader :current

    def connect( host, port, username, password=nil )
      @current = self.new( host, port, username )
      @current.login( password )  if password
      @current
    end

    def get( path, params )
      current.get( path, params )
    end
  end
end

