
module Search

  module Cache

    class FallThrough
      def include?( position, player )
        false
      end

      def get( position, player )
        {}
      end

      def put( position, player, score )
        score
      end 

      def size
        0
      end
    end


    class Memory
      def initialize
        @cache = {}
      end

      def include?( position, player )
        @cache.key? [position, player]
      end

      def size
        @cache.keys.length
      end

      def get( position, player )
        @cache[[position, player]]
      end

      def put( position, player, score )
        @cache[[position, player]] = score
      end
    end


  end

end

