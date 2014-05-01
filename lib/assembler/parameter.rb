module Assembler
  class Parameter
    attr_reader :name

    def initialize(name, options = {})
      @name         = name.to_sym
      @options      = options
    end

    def name_and_aliases
      @name_and_aliases ||= [name] + aliases.map(&:to_sym)
    end

    def coerce_value(value)
      if !coercion
        value
      elsif coercion.kind_of?(Symbol)
        value.send(coercion)
      elsif coercion.respond_to?(:call)
        coercion.call(value)
      else
        raise ArgumentError, "don't know how to handle coerce value #{coercion}"
      end
    end

    def has_default?
      options.has_key?(:default)
    end

    def default
      options[:default]
    end

    private

    attr_reader :options

    def coercion
      options[:coerce]
    end

    def aliases
      @aliases ||= Array(options[:aliases]) + Array(options[:alias])
    end
  end
end
