# frozen_string_literal: true

require_relative '../test_helper'

class TestVyingGames < Minitest::Test
  def test_version
    assert(Vying::Games.version)
  end
end
