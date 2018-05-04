# frozen_string_literal: true

# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

# Add ruby 1.8 and 1.9 compatibility to Module.  Also, add helper methods.

class Module
  # Add instance_variable_defined? for ruby 1.8.  This is used in place of
  # instance_variables.include? because instance_variables has different
  # return values under ruby 1.8 and 1.9 (String vs Symbol).

  unless defined?(:instance_variable_defined?)
    o = Object.new
    o.instance_variable_set('@instance_variable', true)
    case o.instance_variables.first
      when Symbol

        def instance_variable_defined?(iv)
          instance_variables.include?(iv.to_sym)
        end

      when String

        def instance_variable_defined?(iv)
          instance_variables.include?(iv.to_s)
        end

    end
  end

  # Add instance_method_defined? because instance_methods has different
  # return values under ruby 1.8 and ruby 1.9 (String vs Symbol).  This
  # makes the usual means of checking whether an instance method is defined
  # via instance_methods.include? break.

  unless Module.method_defined?(:instance_method_defined?)
    case Module.instance_methods.first
      when Symbol
        def instance_method_defined?(m)
          instance_methods.include?(m.to_sym)
        end

      when String

        def instance_method_defined?(m)
          instance_methods.include?(m.to_s)
        end

    end
  end

  # Add private_instance_method_defined?.  See instance_method_defined?
  # for rationale.

  unless Module.method_defined?(:private_instance_method_defined?)
    case Object.private_instance_methods.first
      when Symbol

        def private_instance_method_defined?(m)
          private_instance_methods.include?(m.to_sym)
        end

      when String

        def private_instance_method_defined?(m)
          private_instance_methods.include?(m.to_s)
        end

    end
  end

end
