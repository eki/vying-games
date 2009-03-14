
require 'test/unit'
require 'vying'

class TestFormat < Test::Unit::TestCase

  def test_list
    Vying::Format.list.each do |n|
      assert( n.ancestors.include?( Vying::Format ) )
    end

    assert( Vying::Format.list.length, Vying::Format.list.uniq.length )
  end

  def test_find
    assert( ! Vying::Format.find( :foo_bar ) )
  end

end

