
require_relative '../../test_helper'

class TestYamlFormat < Minitest::Test
  include Vying

  def test_type
    assert_equal( :yaml, YamlFormat.type )
  end

  def test_find
    assert_equal( YamlFormat, Format.find( :yaml ) )
  end

  def test_dump_rules
    g = Game.new TicTacToe

    h = YAML.load( g.to_format( :yaml ) )

    assert( h['rules'] )

    assert_equal( TicTacToe.name, h['rules']['name'] )
    assert_equal( TicTacToe.to_sc, h['rules']['id'] )
    assert_equal( TicTacToe.version, h['rules']['version'] )
  end

  def test_load_rules
    g = Vying.load( Game.new( TicTacToe ).to_format( :yaml ), :yaml )

    assert_equal( TicTacToe, g.rules )
  end

  def test_dump_history
    g = Game.new TicTacToe

    h = YAML.load( g.to_format( :yaml ) )

    assert_equal( [], h['history'] )

    g << g.moves.first  until g.final?

    h = YAML.load( g.to_format( :yaml ) )

    assert( h['history'] )

    g.history.moves.each_with_index do |m,i|
      assert_equal( m.to_s, h['history'][i]['move'] )
      assert_equal( m.by.to_s, h['history'][i]['by'] )
      assert_equal( m.at.to_i, h['history'][i]['at'].to_i )
    end
  end

  def test_load_history
    g = Game.new( TicTacToe )
    g2 = Vying.load( g.to_format( :yaml ), :yaml )

    assert_equal( g.history, g2.history )

    g << g.moves.first  until g.final?

    g2 = Vying.load( g.to_format( :yaml ), :yaml )

    assert_equal( g.sequence, g2.sequence )

    g.history.moves.each_with_index do |m,i|
      assert_equal( m.to_s, g2.history.moves[i].to_s )
      assert_equal( m.by, g2.history.moves[i].by )
      assert_equal( m.at.to_i, g2.history.moves[i].at.to_i )
      assert_equal( m, g2.history.moves[i] )
    end

  end

  def test_dump_options
    g = Game.new TicTacToe

    h = YAML.load( g.to_format( :yaml ) )

    assert( ! h['options'] )

    g = Game.new Hex, :board_size => 9

    h = YAML.load( g.to_format( :yaml ) )

    assert( h['options'] )
    assert_equal( g.options[:board_size], h['options']['board_size'] )
  end

  def test_load_options
    g = Vying.load( Game.new( TicTacToe ).to_format( :yaml ), :yaml )

    assert_equal( {}, g.options )

    g = Game.new Hex, :board_size => 9
    g = Vying.load( g.to_format( :yaml ), :yaml )

    assert_equal( { :board_size => 9 }, g.options )
  end

  def test_dump_players
    g = Game.new TicTacToe

    h = YAML.load( g.to_format( :yaml ) )

    assert( h['players'] )
    assert_equal( {}, h['players']['x'] )
    assert_equal( {}, h['players']['o'] )

    g << g.moves.first until g.final?

    h = YAML.load( g.to_format( :yaml ) )

    assert( h['players'] )

    assert_equal( g[:x].winner?, h['players']['x']['winner'] )
    assert_equal( g[:o].loser?,  h['players']['o']['loser'] )

    assert( ! h['players']['x']['user'] )

    g[:x].user = User.new( 'john_doe', 1234 )

    h = YAML.load( g.to_format( :yaml ) )

    assert( h['players']['x']['user'] )

    assert_equal( 'john_doe', h['players']['x']['user']['username'] )
    assert_equal( 1234,       h['players']['x']['user']['id'] )
  end

  def test_load_players
    g = Game.new( TicTacToe )
    g2 = Vying.load( g.to_format( :yaml ), :yaml )

    assert_equal( g[:o].user, g2[:o].user )
    assert_equal( g[:x].user, g2[:x].user )

    g[:o].user = User.new( "john_doe", 1234 )

    g2 = Vying.load( g.to_format( :yaml ), :yaml )

    assert_equal( g[:o].user, g2[:o].user )
    assert_equal( g[:o].username, g2[:o].username )
    assert_equal( g[:o].user.id, g2[:o].user.id )
  end

  def test_dump_final
    g = Game.new TicTacToe

    h = YAML.load( g.to_format( :yaml ) )

    assert( ! h['final'] )
    assert( ! h['draw'] )

    g << g.moves.first until g.final?

    h = YAML.load( g.to_format( :yaml ) )

    assert( h['final'] )
    assert( h.key?( 'draw' ) )
  end

  def test_dump_random
    g = Game.new TicTacToe

    h = YAML.load( g.to_format( :yaml ) )
  
    assert( ! h['random'] )

    g = Game.new Ataxx

    h = YAML.load( g.to_format( :yaml ) )
  
    assert( h['random'] )
    assert_equal( g.seed, h['random']['seed'] )
  end

  def test_dump_annotations
    g = Game.new TicTacToe

    h = YAML.load( g.to_format( :yaml ) )
  
    assert( ! h.key?( 'id' ) )
    assert( ! h.key?( 'unrated' ) )
    assert( ! h.key?( 'time_limit' ) )

    assert_equal( g.created_at.to_i, h['created_at'].to_i )
    assert_equal( g.last_move_at.to_i, h['last_move_at'].to_i )

    g.instance_variable_set( '@id', 1234 )
    g.instance_variable_set( '@unrated', true )
    g.instance_variable_set( '@time_limit', 4321 )

    h = YAML.load( g.to_format( :yaml ) )
  
    assert_equal( g.id, h['id'] )
    assert_equal( g.unrated?, h['unrated'] )
    assert_equal( g.time_limit, h['time_limit'] )
  end

  def test_load_annotations
    g = Game.new( TicTacToe )
    g2 = Vying.load( g.to_format( :yaml ), :yaml )

    assert( ! g2.id )
    assert( ! g2.unrated )
    assert( ! g2.time_limit )

    assert_equal( g.created_at.to_i, g2.created_at.to_i )
    assert_equal( g.last_move_at.to_i, g2.last_move_at.to_i )

    g << g.moves.first

    sleep( 1 )

    g.instance_variable_set( '@id', 1234 )
    g.instance_variable_set( '@unrated', true )
    g.instance_variable_set( '@time_limit', 4321 )

    g2 = Vying.load( g.to_format( :yaml ), :yaml )

    assert_equal( 1234, g2.id )
    assert( g2.unrated )
    assert_equal( 4321, g2.time_limit )
    assert_equal( g.created_at.to_i, g2.created_at.to_i )
    assert_equal( g.last_move_at.to_i, g2.last_move_at.to_i )
  end
end

