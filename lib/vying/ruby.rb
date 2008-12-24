# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

# Add ruby 1.8 and 1.9 compatibility to String.  (Not complete, only where
# needed by vying).

class String

  # Compatibility with Ruby 1.9

  unless method_defined?( :ord )
    def ord
      self[0]
    end
  end
end

# Add ruby 1.8 and 1.9 compatibility to Module.  Also, add helper methods.

class Module

  # Like Module#const_get with the exception that this handles nested
  # constants.  For example, Move::Draw::PositionMixin can be found
  # via nested_const_get.

  def nested_const_get( s )
    o = [Object, Module, Kernel].include?( self ) ? Object : self

    s.to_s.split( /::/ ).inject( o ) do |n,m| 
      n && n.w_const_defined?( m ) ? n.w_const_get( m ) : nil
    end
  end

  # Like Module#const_get with the exception that this handles nested
  # constants.  For example, Move::Draw::PositionMixin can be found
  # via nested_const_get.

  def nested_const_defined?( s )
    o = [Object, Module, Kernel].include?( self ) ? Object : self

    !! s.to_s.split( /::/ ).inject( o ) do |n,m| 
      n && n.w_const_defined?( m ) ? n.w_const_get( m ) : false
    end
  end

  # Add a wrapper around const_get that deals with compatibility between 
  # ruby 1.8 and ruby 1.9.  The original const_get is left untouched so
  # as not to effect any outside code that depends on its 1.8 or 1.9 behavior.

  if method( :const_get ).arity == -1
    def w_const_get( k )
      const_get( k, false )
    end
  else
    alias_method :w_const_get, :const_get
  end

  # Add a wrapper around const_defined? that deals with compatibility between 
  # ruby 1.8 and ruby 1.9.  The original const_defined? is left untouched so
  # as not to effect any outside code that depends on its 1.8 or 1.9 behavior.

  if method( :const_defined? ).arity == -1
    def w_const_defined?( k )
      const_defined?( k, false )
    end
  else
    alias_method :w_const_defined?, :const_defined?
  end

  # Add instance_variable_defined? for ruby 1.8.  This is used in place of
  # instance_variables.include? because instance_variables has different
  # return values under ruby 1.8 and 1.9 (String vs Symbol).

  unless defined?( :instance_variable_defined? )
    o = Object.new
    o.instance_variable_set( "@instance_variable", true )
    case o.instance_variables.first
      when Symbol 

        def instance_variable_defined?( iv ) 
          instance_variables.include?( iv.to_sym )
        end

      when String 

        def instance_variable_defined?( iv )
          instance_variables.include?( iv.to_s ) 
        end 

    end 
  end

  # Add instance_method_defined? because instance_methods has different
  # return values under ruby 1.8 and ruby 1.9 (String vs Symbol).  This
  # makes the usual means of checking whether an instance method is defined
  # via instance_methods.include? break.

  unless Module.method_defined?( :instance_method_defined? )
    case Module.instance_methods.first
      when Symbol 
        def instance_method_defined?( m ) 
          instance_methods.include?( m.to_sym )
        end

      when String 

        def instance_method_defined?( m )
          instance_methods.include?( m.to_s ) 
        end 

    end 
  end

  # Add private_instance_method_defined?.  See instance_method_defined?
  # for rationale.

  unless Module.method_defined?( :private_instance_method_defined? )
    case Object.private_instance_methods.first
      when Symbol 

        def private_instance_method_defined?( m ) 
          private_instance_methods.include?( m.to_sym )
        end

      when String 

        def private_instance_method_defined?( m )
          private_instance_methods.include?( m.to_s ) 
        end 

    end 
  end

end

