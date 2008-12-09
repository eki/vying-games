# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'optparse'
require 'vying'
require 'vying/http'

begin
  require 'rubygems'
  require 'highline/import'
rescue LoadError
  puts "LoadError: This command depends on RubyGems and the highline gem."
  exit
end

module CLI
  
  def CLI.login
    params = { :username  => nil,
               :prompt    => true,
               :host      => "vying.org",
               :port      => 80,
               :debug     => false }

    opts = OptionParser.new
    opts.banner = "Usage: vying login [options]"
    opts.on( "-s", "--host [HOST]"   ) { |h| params[:host] = h       }
    opts.on( "-p", "--port [PORT]"   ) { |p| params[:port] = p       }
    opts.on( "-u", "--user USERNAME" ) { |u| params[:username] = u   }
    opts.on(       "--no-prompt"     ) {     params[:prompt] = false }
    opts.on(       "--debug"         ) {     params[:debug] = true   }

    opts.parse( ARGV )

    Vying::Server.connect( params ) do |c|

      if r = c.get( "/api/login" )
        puts r['status']

        if params[:prompt] && ! r['username']
          pass = ask( "Password: " ) { |q| q.echo = '*' }
          if c.login( pass, true )
            puts "Login successful."
          else
            puts "Login failed!"
          end
        end
      end

    end

  end

end

