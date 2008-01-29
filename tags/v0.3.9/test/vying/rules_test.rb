require 'test/unit'

require 'vying'

class TestRules < Test::Unit::TestCase
  def test_find
    Rules.list.each do |r|
      assert_equal( r, Rules.find( r.to_snake_case ) )
      assert_equal( r, Rules.find( r.to_s ) )
      assert_equal( r, Rules.find( r.to_s.downcase ) )
    end

    assert_nil( Rules.find( "foo_bar" ) )
  end
end

