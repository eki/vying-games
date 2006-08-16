
# Stolen from:
#   http://blog.grayproductions.net/articles/2006/01/20/caching-and-memoization
#
# Changed cache[args] to cache[self,args]
#   Seemed more correct to include self, as different objects may have
#   different state, which could effect the results of the call
#

module Memoizable
  def memoize( name, cache = Hash.new )
    original = "__unmemoized_#{name}__"

    ([Class, Module].include?(self.class) ? self : self.class).class_eval do
      alias_method original, name
      private      original
      define_method(name) do |*args| 
        cache[[self,args]] ||= send(original, *args)
      end
    end
  end
end

