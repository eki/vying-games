# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

module CLI

  SUBCOMMANDS = %w(bench bot bot_rank branch play login).freeze

  def self.subcommand?(s)
    SUBCOMMANDS.include?(s)
  end

  def self.require_subcommand(s)
    require "vying/cli/#{s}"
  end

end
