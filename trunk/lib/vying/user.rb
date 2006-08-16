
class UserDelegate
  attr_reader :user_id, :username

  def initialize( user_id=0, username='anonymous' )
    @user_id, @username = user_id, username
  end
end

