# frozen_string_literal: true

# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

module Vying

  # Format.

  class Format

    # Requires all format files.

    def self.require_all
      Dir.glob("#{Vying.root}/lib/vying/formats/**/*.rb") do |f|
        require f.to_s
      end
    end

    # When a subclass extends Format, it is added to Format.list.

    def self.inherited(child)
      list << child
    end

    # Get a list of all Format subclasses.

    def self.list
      @list ||= []
    end

    # Find a specific Format by type

    def self.find(type)
      list.find { |f| f.type == type }
    end

  end

  def self.load(string, type)
    format = Format.find(type)

    raise "Couldn't find format for type #{type}" unless format

    format.new.load(string)
  end

  def self.dump(game, type)
    format = Format.find(type)

    raise "Couldn't find format for type #{type}" unless format

    format.new.dump(game)
  end
end
