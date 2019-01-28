# frozen_string_literal: true

module Search

  module Cache

    # The FallThrough Cache is not a cache at all.  It implements the search
    # cache interface, but acts as a black hole -- you can never get anything
    # out of it.

    class FallThrough
      def include?(position, player, depth)
        false
      end

      def get(position, player)
        nil
      end

      def put(position, player, score, depth)
        [score, depth]
      end

      def size
        0
      end
    end

    # CacheRecord is used by the Memory cache.

    CacheRecord = Struct.new(:score, :distance, :hits)

    # Cache search results in memory.

    class Memory
      attr_reader :limit

      # Initialize the cache with the given size limit.  If putting a score
      # into the cache cause the limit to be exceeded the least often accessed
      # scores will be removed.

      def initialize(limit=1000)
        @cache, @limit = {}, limit
      end

      # Is there a score in this cache for the given [position,  player] that
      # meets the given depth requirement.

      def include?(position, player, depth)
        args = [position, player]
        @cache.key?(args) && @cache[args].distance >= depth
      end

      # How big is the cache right now?

      def size
        @cache.keys.length
      end

      # Fetch a cached score for the given [position, player].  The score
      # *and* the distance are returned.  The distance can be thought of as
      # an indication of confidence.  If the score for the given position
      # was calculated when the position was at a leaf node, the distance
      # is 0.  If the position was 3-ply from the leaf node, the distance is
      # 3.  This can also be thought of in this way:  The score was arrived
      # at by executing a minimax search of depth _distance_.
      #
      # The cache has no way of calculating the distance, it's given with
      # the score by #put.

      def get(position, player)
        cr = @cache[[position, player]]
        if cr
          cr.hits += 1
          return [cr.score, cr.distance]
        end
      end

      # Cache the given [score, distance] with [position, player] as the
      # key.  For a discussion of distance, see #get.

      def put(position, player, score, distance)
        old = @cache[[position, player]]

        if !old || old.distance < distance
          @cache[[position, player]] = CacheRecord.new(score, distance, 0)
        end

        expire

        [score, distance]
      end

      # Expire values from the cache.  After a call to expire, the cache
      # will always be under the limit.

      def expire
        return if size < limit

        hit_limit = 1

        until size < limit - limit / 10
          @cache.reject! { |k, cr| cr.hits < hit_limit }
          hit_limit += 1
        end
      end

      # Get the values stored in the cache.  See CacheRecord.

      def values
        @cache.values
      end

      # Get the [position, player] keys.

      def keys
        @cache.keys
      end
    end

  end

end
