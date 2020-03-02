# frozen_string_literal: true

module Vying::Games

  # Represents the default and valid values for an option used with
  # Rules#start, and Rules#validate.

  class Option
    attr_reader :name, :default, :values

    def initialize(name, opts={})
      @name, @default, @values = name, opts[:default], opts[:values]

      raise 'default required for option'  unless @default
      raise 'values required for option'   unless @values

      unless @values.include?(@default)
        raise 'values must include the default'
      end
    end

    def coerce(value)
      if default.kind_of?(Symbol)
        value = value.to_sym
      elsif default.kind_of?(Integer) && !value.kind_of?(Symbol)
        value = value.to_i
      elsif default.kind_of?(Float)
        value = value.to_f
      elsif default.kind_of?(String)
        value = value.to_s
      end

      value
    end

    def validate(value)
      value = coerce(value)

      unless values.include?(value)
        raise "#{value.inspect} is not valid for #{name}, try #{values.inspect}"
      end

      true
    end
  end
end
