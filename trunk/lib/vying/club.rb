
class Message
  attr_reader :to, :from, :date, :body, :where

  def initialize( to, from, body, date, where )
    @to, @from, @body, @date, @where = to, from, body, date, where
  end

  def to_s
    "#{from}: #{body}"
  end
end


class Table
  attr_reader :name, :room, :users

  def initialize( name, room )
    @name, @room, @users = name, room, []
    @room.tables << self
  end

  def say( body, from, to = [:all], where = self )
    to << users if to.delete :all

    room.say( body, from, to, where )
  end

  def hear( user, where = self )
    room.hear( user, where )
  end

  def enter( user )
    @room.enter( user )
    @users << user unless @users.include? user
  end

  def leave( user )
    @users.delete( user )
  end

  def to_s
    s = "    - #{name} (Table) \n"
    users.each { |u| s << "      - #{u} (User) \n" }
    s
  end
end

class Room
  attr_reader :name, :club, :users, :tables

  def initialize( name, club )
    @name, @club, @users, @tables = name, club, [], []
    @club.rooms << self
  end

  def say( body, from, to = [:all], where = self )
    to << users if to.delete :all

    club.say( body, from, to, where )
  end

  def hear( user, where = self )
    club.hear( user, where )
  end

  def enter( user )
    @club.enter( user )
    @users << user unless @users.include? user
  end

  def leave( user )
    @tables.each { |t| t.leave( user ) }
    @users.delete( user )
  end

  def to_s
    s = "  - #{name} (Room) \n"
    tables.each { |t| s << t.to_s }
    users.each { |u| s << "    - #{u} (User) \n" }
    s
  end

  def table( hash = {} )
    hash = { :name => "#{name}#{tables.length}" }.merge!( hash )
    Table.new( hash[:name], self )
  end
end

class Club
  attr_reader :name, :users, :rooms, :messages

  def initialize( name, &block )
    @name, @rooms, @users = name, [], []
    @messages = Hash.new { |h,k| h[k] = [] }
    instance_eval( &block )
  end

  def say( body, from, to = [:all], where = self )
    to << users if to.delete :all
    to.flatten!.uniq!

    to.each do |u| 
      @messages[u] << Message.new( u, from, body, Time.now, where )
    end 
  end

  def hear( user, where = self )
    if where == :all
      @messages[user], a = [], @messages[user]
    else
      a = @messages[user].select { |m| m.where == where }
      @messages[user].clear
    end
    
    return a
  end

  def enter( user )
    @users << user unless @users.include? user
  end

  def leave( user )
    @rooms.each { |r| r.leave( user ) }
    @users.delete( user )
  end

  def []( path )
    return self if path == name
    rooms.each do |r|
      return r if path == "#{r.name}.#{name}"
      r.tables.each do |t|
        return t if path == "#{t.name}.#{r.name}.#{name}"
      end
    end
    nil
  end

  def to_s
    s = "#{name} (Club) \n"
    rooms.each { |r| s << r.to_s }
    s
  end

  def room( hash = {} )
    hash = { :name => "Unnamed", :number_of_tables => 5 }.merge!( hash )
    r = Room.new( hash[:name], self )
    hash[:number_of_tables].times { |i| r.table }
    r
  end
end

