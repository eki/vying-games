
class User
  attr_reader :id, :username

  def initialize( username=nil, id=nil )
    @username, @id = username, id
  end

  def eql?( u )
    username == u.username
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
end

