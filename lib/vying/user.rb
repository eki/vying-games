
class User
  attr_reader :id, :username

  alias_method :user_id, :id

  def initialize( username=nil, id=nil )
    @username, @id = username, id
  end

  def bot?
    false
  end

  def ready?
    false
  end

  def select( sequence, position, player )
    raise "User doesn't implement #select"
  end

  def resign?( sequence, position, player )
    false
  end

  def offer_draw?( sequence, position, player )
    false
  end

  def accept_draw?( sequence, position, player )
    false
  end

  def request_undo?( sequence, position, player )
    false
  end

  def accept_undo?( sequence, position, player )
    false
  end

  def eql?( u )
    u && username == u.username
  end

  def ==( u )
    eql? u
  end

  def hash
    username.hash
  end

  def to_user
    self
  end

  def to_s
    username
  end

  # Take over YAML deserialization.  Try to look up Bots by username, otherwise
  # returns a User object.

  def self.yaml_new( klass, tag, val )
    Bot.find( val['username'] ) || User.new( val['username'], val['id'] )
  end

  def to_yaml_properties
    ["@username", "@id"]
  end

end

# This is just a simple dummy Human bot class.  It accepts moves into a 
# queue via #<< and then plays them when asked for a move by Game#step and
# Game#play.
#

class Human < User
  attr_reader :queue

  def initialize( *args )
    super
    @queue = []
  end

  def <<( move )
    queue << move 
  end

  def select( sequence, position, player )
    queue.shift
  end

  def resign?( sequence, position, player )
    queue.shift if queue.first == "resign"
  end

  def offer_draw?( sequence, position, player )
    queue.shift if queue.first == "offer_draw"
  end

  def accept_draw?( sequence, position, player )
    return   queue.shift if queue.first == "accept_draw"
    return ! queue.shift if queue.first == "reject_draw"
  end

  def request_undo?( sequence, position, player )
    queue.shift if queue.first == "request_undo"
  end

  def accept_undo?( sequence, position, player )
    return   queue.shift if queue.first == "accept_undo"
    return ! queue.shift if queue.first == "reject_undo"
  end

  def ready?
    ! @queue.empty?
  end

  def to_yaml( opts={} )
    User.new( username, id ).to_yaml( opts )
  end
end

