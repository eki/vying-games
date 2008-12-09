

class Vying::Server
  attr_reader :host, :port, :session, :username, :auth_token

  def initialize( params={} )
    @host, @port, @username = params[:host], params[:port], params[:username]
    @auth_token = params[:auth_token]
    
    @logged_in = !! @auth_token

    @debug = params[:debug]
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

  def debug?
    !! @debug
  end

  def update_cookies( cookies )
    h = {}
    cookies.each do |c|
      n, v = c.split( ";" ).first.split( "=" )
      h[n] = v
    end

    @session = h['_session_id']  if h['_session_id'] != session

    if h['auth_token'] && h['auth_token'] != auth_token
      @auth_token = h['auth_token']
      save_auth_token
    end
  end

  def get( path, params={} )
    unless params.empty?
      path += "?"
      path += params.map { |n,v| "#{n}=#{v}" }.join( "&" )
    end

    puts "get path: #{path}"  if debug?

    headers = {}

    if c = cookie
      headers['Cookie'] = c
    end

    http = Net::HTTP.new( host, port )
    response = http.get( path, headers )

    update_cookies( response.get_fields( 'set-cookie' ) )

    if response.code == "200"
      open( "./last.yaml", "w" ) { |f| f.puts response.body }  if debug?

      YAML.load( response.body )
    else
      nil
    end
  end

  def post( path, params={} )
    data =  params.map { |n,v| "#{n}=#{v}" }.join( "&" )

    puts "post path: #{path}"  if debug?

    headers = {}

    if c = cookie
      headers['Cookie'] = c
    end

    http = Net::HTTP.new( host, port )
    response = http.post( path, data, headers )

    update_cookies( response.get_fields( 'set-cookie' ) )

    if response.code == "200"
      open( "./last.yaml", "w" ) { |f| f.puts response.body }  if debug?

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

  def save_auth_token
    self.class.create_cookie_dir

    fn = File.expand_path( 
      "~/.vying/cookies/#{username}_#{host}_#{port}_auth_token.txt" )

    open( fn, "w" ) do |f|
      f.puts "auth_token=#{auth_token};"
    end
  end

  def delete_auth_token
    self.class.create_cookie_dir

    fn = File.expand_path( 
      "~/.vying/cookies/#{username}_#{host}_#{port}_auth_token.txt" )

    File.delete( fn )  if File.exists?( fn )
  end

  class << self
    def current
      @current || connect
    end

    def connect( params={} )
      params.merge!( load_auth_token( params ) )

      @current = new( params )

      yield @current  if block_given?

      @current
    end

    def get( path, params={} )
      current.get( path, params )
    end

    def post( path, params={} )
      current.post( path, params )
    end

    def create_vying_dir
      d = File.expand_path( "~/.vying" )

      unless File.exists?( d )
        old_mask = File.umask( 0022 )
        Dir.mkdir( d )
        File.umask( old_mask )
      end
    end

    def create_cookie_dir
      create_vying_dir

      d = File.expand_path( "~/.vying/cookies" )

      unless File.exists?( d )
        old_mask = File.umask( 0077 )
        Dir.mkdir( d )
        File.umask( old_mask )
      end
    end

    def load_auth_token( params={} )
      create_cookie_dir

      host = params[:host] || '*'
      port = params[:port] || '*'
      username = params[:username] || '*'

      d = File.expand_path( "~/.vying/cookies" )

      fn = Dir.glob( "#{d}/#{username}_#{host}_#{port}_auth_token.txt" ).first

      h = {}

      if fn
        h[:auth_token] = File.open( fn, "r" ).read.split( /[=;\n]/ ).last
        if fn =~ /\/(\w+)_(.+)_(\d+)_auth_token.txt/
          h[:username] = $1
          h[:host] = $2
          h[:port] = $3.to_i
        end
      end

      h
    end
  end
end

