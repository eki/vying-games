# frozen_string_literal: true

# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/games'

module Vying::Games

  # Utility methods related to counting subsets.

  module Subset
    class << self

      def factorial(n)
        return 1 if n < 2

        (1..n).inject { |a, b| a * b }
      end

      def count_subsets(n, m)
        return 1 if n == 0

        factorial(m) / (factorial(n) * factorial(m - n))
      end

      def count_subsets_less_than(n, m)
        (0..n).inject(0) { |a, b| a + count_subsets(b, m) }
      end

      extend Memoizable

      memoize :factorial
      memoize :count_subsets
      memoize :count_subsets_less_than

    end
  end
end
