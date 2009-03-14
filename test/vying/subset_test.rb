
require 'test/unit'
require 'vying'

class TestSubset < Test::Unit::TestCase
  include Vying

  def test_count_subsets
    assert_equal( 1,  Subset.count_subsets( 0, 1 ) )
    assert_equal( 1,  Subset.count_subsets( 0, 2 ) )
    assert_equal( 1,  Subset.count_subsets( 0, 3 ) )
    assert_equal( 1,  Subset.count_subsets( 0, 10 ) )

    assert_equal( 1,  Subset.count_subsets( 1, 1 ) )
    assert_equal( 2,  Subset.count_subsets( 1, 2 ) )
    assert_equal( 3,  Subset.count_subsets( 1, 3 ) )
    assert_equal( 10, Subset.count_subsets( 1, 10 ) )

    assert_equal( 3,  Subset.count_subsets( 2, 3 ) )
    assert_equal( 6,  Subset.count_subsets( 2, 4 ) )
    assert_equal( 10, Subset.count_subsets( 2, 5 ) )
    assert_equal( 45, Subset.count_subsets( 2, 10 ) )

    assert_equal( 3,  Subset.count_subsets( 1, 3 ) )
    assert_equal( 6,  Subset.count_subsets( 2, 4 ) )
    assert_equal( 10, Subset.count_subsets( 3, 5 ) )
    assert_equal( 45, Subset.count_subsets( 8, 10 ) )
  end

  def test_total_count_subsets_less_than
    assert_equal( Subset.count_subsets( 0, 5 ) +
                  Subset.count_subsets( 1, 5 ) +
                  Subset.count_subsets( 2, 5 ) +
                  Subset.count_subsets( 3, 5 ),
                  Subset.count_subsets_less_than( 3, 5 ) )
  end
end
