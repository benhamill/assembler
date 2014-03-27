module Assembler
  class Builder
    def initialize(parameters_hash, options = {})
      @options = options
      @parameters_hash = parameters_hash

      parameters_hash.each do |parameter_name, parameter|
        parameter.name_and_aliases.each do |name_or_alias|
          self.singleton_class.class_eval(<<-RUBY)
            def #{name_or_alias}=(value)
              options[:#{parameter_name.to_sym}] = value
            end

            def #{name_or_alias}
              parameters_hash[:#{parameter_name}].value_from(options)
            end
          RUBY
        end
      end
    end

    def to_h
      options
    end

    private

    attr_reader :parameters_hash, :options
  end
end
