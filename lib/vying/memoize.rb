# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.
#
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
        cache[[self,args]] ||= send(original, *args).freeze
      end
    end
  end

  def immutable_memoize( name )
    original = "__unmemoized_#{name}__"

    ([Class, Module].include?(self.class) ? self : self.class).class_eval do
      alias_method original, name
      private      original

      if instance_method( original ).arity == 0

        define_method( name ) do ||   # empty pipes needed to get right arity

          n = name.to_s.gsub( /[?!]/, '_' )
          iv = "@__#{n}_cache"
          v = instance_variable_get( iv )

          return v unless v.nil?

          v = send( original ).freeze
          instance_variable_set( iv, v )

          v
        end

      else

        define_method( name ) do |*args| 
          # Remove trailing nils from args (but keep placeholder nils)
          args.pop while args.last == nil && ! args.empty?

          n = name.to_s.gsub( /[?!]/, '_' )
          iv = "@__#{n}_cache"
          h = instance_variable_get( iv ) || {}
          v = h[args]

          return v unless v.nil?

          h[args] = v = send( original, *args ).freeze
          instance_variable_set( iv, h )

          v
        end

      end
    end
  end
end

class Class
  private
  def prototype
    class_eval do
      class << self
        alias_method :old_new, :new

        private :old_new

        define_method( :new ) do |*args|
          @prototype_cache ||= {}
          (@prototype_cache[args] ||= old_new( *args ).freeze).dup
        end
      end
    end
  end
end

