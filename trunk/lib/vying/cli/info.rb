#!/usr/bin/env ruby

require 'optparse'
require 'vying'

CLI::SUBCOMMANDS << "info"

module CLI

  def CLI.info

    rules = []
    key = nil

    opts = OptionParser.new
    opts.on( "-r", "--rules RULES" ) { |r| rules << Kernel.const_get( r ) }
    opts.on( "-k", "--key KEY"     ) { |k| key = k }

    opts.parse( ARGV )

    rules = Rules.list if rules.empty?

    rules.each do |r|
      if key.nil?
        r.info.each_pair { |k,v| puts "#{k}: #{v}" }
      else
        puts r.info[key]
      end
    end
  end
end
