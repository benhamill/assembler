module Assembler
  class Parameter
    attr_reader :name

    def initialize(name, options = {})
      @name         = name.to_sym
      @options      = options
    end

    def name_and_aliases
      [name] + aliases.map(&:to_sym)
    end

    def value_from(options, &if_missing_required)
      first_key = key_names.find { |name_or_alias| options.has_key?(name_or_alias) }

      if first_key
        return coerce_value(options[first_key])

      elsif has_default?
        return coerce_value(default)

      else
        if_missing_required.call unless if_missing_required.nil?

        return nil
      end
    end

    private

    attr_reader :options

    def key_names
      name_and_aliases.flat_map do |name_or_alias|
        [name_or_alias.to_sym, name_or_alias.to_s]
      end
    end

    def has_default?
      options.has_key?(:default)
    end

    def default
      options[:default]
    end

    def has_coercion?
      options.has_key?(:coerce)
    end

    def coercion
      options[:coerce]
    end

    def coerce_value(value)
      if !has_coercion?
        value
      elsif coercion.kind_of?(Symbol)
        value.send(coercion)
      elsif coercion.respond_to?(:call)
        coercion.call(value)
      else
        raise ArgumentError, "don't know how to handle coerce value #{coercion}"
      end
    end

    def has_aliases?
      options.has_key?(:aliases)
    end

    def aliases
      has_aliases? ? Array(options[:aliases]) : []
    end
  end
end
