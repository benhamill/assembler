module Assembler
  class Parameter
    attr_reader :name

    def initialize(name, options = {})
      @name         = name.to_sym
      @options      = options
    end

    def has_default?
      options.has_key?(:default)
    end

    def default
      options[:default]
    end

    def coerce_value(value=nil)
      value = value || yield

      if has_coercion?
        value.send(coerce)
      else
        value
      end
    end

    private

    attr_reader :options

    def has_coercion?
      options.has_key?(:coerce)
    end

    def coerce
      options[:coerce]
    end
  end
end
