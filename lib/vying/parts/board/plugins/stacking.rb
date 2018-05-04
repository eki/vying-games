# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# This is a stub for a plugin to make it easier to stack pieces on a board.

module Board::Plugins::Stacking
  include Board::Plugins

  # Display the board in such a way that entire stacks can be seen.

  def to_s
    off = height >= 10 ? 2 : 1
    sp = @cells.compact.max_by(&:length)
    sp = sp ? sp.length : 1
    letters = "#{' ' * off}#{('a'...(97 + width).chr).collect { |l| ' ' + l + ' ' * sp }}#{' ' * off}\n"

    s = letters
    height.times do |y|
      s += format('%*d', off, y + 1)
      s += row(y).inject('') do |rs, p|
        stack = p.collect { |x| x.to_s[0..0] }.join if p
        rs + (p ? " #{stack}#{'_' * (sp - stack.length)} " : " #{'_' * sp} ")
      end
      s += format("%*d\n", -off, y + 1)
    end
    s + letters
  end

end
