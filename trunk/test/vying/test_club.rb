require 'test/unit'

require 'vying/club'

class TestMessage < Test::Unit::TestCase
  def test_initialize
    m = Message.new( "romeo", "juliet", "where art thou?", 1000, nil )
    assert_equal( "romeo", m.to )
    assert_equal( "juliet", m.from )
    assert_equal( "where art thou?", m.body )
    assert_equal( 1000, m.date )
    assert_equal( nil, m.where )
  end

  def test_to_s
    m = Message.new( "romeo", "juliet", "where art thou?", 1000, nil )
    assert_equal( "juliet: where art thou?", m.to_s )
  end
end

class TestClub < Test::Unit::TestCase
  def test_initialize
    club = Club.new( "games.vying.org" ) do
      room :name => "othello"
      room :name => "pig", :number_of_tables => 1
      room :name => "amazons", :number_of_tables => 12
    end

    assert_equal( 3, club.rooms.length )

    assert_equal( "othello", club["othello.games.vying.org"].name )
    assert_equal( "pig", club["pig.games.vying.org"].name )
    assert_equal( "amazons", club["amazons.games.vying.org"].name )

    assert_equal( 5, club["othello.games.vying.org"].tables.length )
    assert_equal( 1, club["pig.games.vying.org"].tables.length )
    assert_equal( 12, club["amazons.games.vying.org"].tables.length )

    hearts = club.room( :name => "hearts", :number_of_tables => 2 )

    assert_equal( hearts, club["hearts.games.vying.org"] )

    assert_equal( %w(hearts0 hearts1 ), hearts.tables.map { |t| t.name } )
  end

  def test_club_enter_leave
    club = Club.new( "games.vying.org" ) do
      room :name => "othello"
      room :name => "pig", :number_of_tables => 1
      room :name => "amazons", :number_of_tables => 12
    end

    assert_equal( [], club.users )

    club.enter( "foo" )
    assert_equal( ["foo"], club.users )

    club.enter( "bar" )
    assert_equal( ["foo", "bar"], club.users )

    club.enter( "baz" )
    assert_equal( ["foo", "bar", "baz"], club.users )

    club.leave( "bar" )
    assert_equal( ["foo", "baz"], club.users )

    club.leave( "baz" )
    assert_equal( ["foo"], club.users )

    club.enter( "bar" )
    assert_equal( ["foo", "bar"], club.users )

    club.leave( "foo" )
    assert_equal( ["bar"], club.users )

    club.leave( "bar" )
    assert_equal( [], club.users )
  end

  def test_room_enter_leave
    othello, pig, amazons = nil, nil, nil
    club = Club.new( "games.vying.org" ) do
      othello = room :name => "othello"
      pig     = room :name => "pig", :number_of_tables => 1
      amazons = room :name => "amazons", :number_of_tables => 12
    end


    assert_equal( [], club.users )
    assert_equal( [], othello.users )
    assert_equal( [], pig.users )
    assert_equal( [], amazons.users )

    club.enter( "foo" )
    othello.enter( "foo" )
    othello.enter( "bar" )
    pig.enter( "baz" )
    amazons.enter( "foo" )

    assert_equal( ["foo", "bar", "baz"], club.users )
    assert_equal( ["foo", "bar"], othello.users )
    assert_equal( ["baz"], pig.users )
    assert_equal( ["foo"], amazons.users )

    club.leave( "bar" )
    othello.leave( "foo" )
    pig.leave( "baz" )
    
    assert_equal( ["foo", "baz"], club.users )
    assert_equal( [], othello.users )
    assert_equal( [], pig.users )
    assert_equal( ["foo"], amazons.users )
  end

  def test_table_enter_leave
    othello, amazons = nil, nil
    club = Club.new( "g.v.o" ) do
      othello = room :name => "othello", :number_of_tables => 2
      amazons = room :name => "amazons", :number_of_tables => 1
    end

    assert_equal( [], club.users )
    assert_equal( [], othello.users )
    assert_equal( [], othello.tables[0].users )
    assert_equal( [], othello.tables[1].users )
    assert_equal( [], amazons.users )
    assert_equal( [], amazons.tables[0].users )

    club.enter( "foo" )
    othello.enter( "bar" )
    othello.tables[0].enter( "bar" )
    othello.tables[1].enter( "foo" )
    amazons.tables[0].enter( "baz" )

    assert_equal( ["foo", "bar", "baz"], club.users )
    assert_equal( ["bar", "foo"], othello.users )
    assert_equal( ["bar"], othello.tables[0].users )
    assert_equal( ["foo"], othello.tables[1].users )
    assert_equal( ["baz"], amazons.users )
    assert_equal( ["baz"], amazons.tables[0].users )

    club.leave( "foo" )
    othello.leave( "bar" )
    amazons.tables[0].leave( "baz" )

    assert_equal( ["bar", "baz"], club.users )
    assert_equal( [], othello.users )
    assert_equal( [], othello.tables[0].users )
    assert_equal( [], othello.tables[1].users )
    assert_equal( ["baz"], amazons.users )
    assert_equal( [], amazons.tables[0].users )
  end

  def test_say_hear_01
    othello, amazons = nil, nil
    club = Club.new( "g.v.o" ) do
      othello = room :name => "othello", :number_of_tables => 2
      amazons = room :name => "amazons", :number_of_tables => 1
    end

    table = othello.tables[0]
    
    othello.enter( "foo" )
    table.enter( "bar" )
    table.enter( "baz" )

    table.say( "what up, baz?", "bar" )

    for_foo = table.hear( "foo" )
    for_bar = table.hear( "bar" )
    for_baz = table.hear( "baz" )

    assert_equal( [], for_foo )
    assert_equal( "bar", for_bar[0].from )
    assert_equal( "bar", for_baz[0].from )
    assert_equal( "bar", for_bar[0].to )
    assert_equal( "baz", for_baz[0].to )
    assert_equal( "what up, baz?", for_bar[0].body )
    assert_equal( "what up, baz?", for_baz[0].body )
  end

end

