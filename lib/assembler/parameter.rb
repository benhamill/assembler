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

    def value_from(hash, &if_required_and_missing)
      @memoized_value_from ||= {}

      # NOTE: Jruby's Hash#hash implementation is BS:
      # {:foo => :foo}.hash => 1
      # {:bar => :bar}.hash => 1
      # {:foo => :foo}.to_a.hash => 806614226
      # {:bar => :bar}.to_a.hash => 3120054328
      # Go figure...
      memoization_key = hash.to_a.hash

      return @memoized_value_from[memoization_key] if @memoized_value_from[memoization_key]

      first_key = key_names.find { |name_or_alias| hash.has_key?(name_or_alias) }

      @memoized_value_from[memoization_key] = coerce_value hash.fetch(first_key) do
        options.fetch(:default) do
          if_required_and_missing.call unless if_required_and_missing.nil?

          return nil
        end
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

    def coercion
      options[:coerce]
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

    def aliases
      @aliases ||= Array(options[:aliases]) + Array(options[:alias])
    end
  end
end
