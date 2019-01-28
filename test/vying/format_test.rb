# frozen_string_literal: true

require_relative '../test_helper'

class TestFormat < Minitest::Test
  include Vying

  def test_list
    Format.list.each do |n|
      assert(n.ancestors.include?(Format))
    end

    assert_equal(Format.list.length, Format.list.uniq.length)
  end

  def test_find
    assert(!Format.find(:foo_bar))
  end

end
