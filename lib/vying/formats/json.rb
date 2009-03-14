
if defined?( JSON )
  module Vying
    class JsonFormat < Format

      def self.type
        :json
      end

      def load( string )
        h = JSON.parse( string )

        h['history'].each do |mh|
          mh['at'] = Time.parse( mh['at'] )
        end

        %w( created_at last_move_at ).each do |k|
          h[k] = Time.parse( h[k] )  if h.key?( k )
        end

        Vying.load( h, :hash )
      end

      def dump( game )
        game.to_format( :hash ).to_json
      end

    end
  end
end

