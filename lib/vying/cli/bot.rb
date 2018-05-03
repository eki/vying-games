# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'optparse'
require 'vying'
require 'vying/http'

begin
  require 'rubygems'
  require 'highline/import'
rescue LoadError
  puts 'LoadError: This command depends on RubyGems and the highline gem.'
  exit
end

module CLI

  def self.bot
    params = { username: nil,
               bot: nil,
               requires: [],
               host: 'vying.org',
               port: 80,
               debug: false }

    opts = OptionParser.new
    opts.banner = 'Usage: vying login [options]'
    opts.on('-s', '--host [HOST]') { |h| params[:host] = h       }
    opts.on('-p', '--port [PORT]') { |p| params[:port] = p       }
    opts.on('-u', '--user USERNAME') { |u| params[:username] = u }
    opts.on('-b', '--bot BOT') { |b| params[:bot] = b        }
    opts.on('-r', '--require FILE') { |r| params[:requires] << r }
    opts.on('--debug') {     params[:debug] = true }

    opts.parse(ARGV)

    params[:requires].each { |r| require r }

    bot = Bot.find(params[:bot]) || Bot.find(params[:username])

    if bot.nil?
      puts 'No bot specified'
      exit
    end

    params[:username] ||= bot.username

    Vying::Server.connect(params) do |c|
      u = User.myself

      while p = u.cycle
        m = bot.select(p.sequence, p, p.you)
        p2 = p.submit_move(m)
      end
    end
  end

end
