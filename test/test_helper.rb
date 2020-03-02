# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('../ext', __dir__)

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'vying/games'
require_relative './vying/rules/rules_test'

require 'minitest/autorun'

class Minitest::Test
end
