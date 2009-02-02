
require 'test/unit'
require 'vying'

class TestFormat < Test::Unit::TestCase

  def test_list
    Format.list.each do |n|
      assert( n.ancestors.include?( Format ) )
    end

    assert( Format.list.length, Format.list.uniq.length )
  end

  def test_find
    assert( ! Format.find( :foo_bar ) )
  end

end

