module Assembler
  class Builder
    attr_reader :assembled_object

    def initialize(object, parameters_hash)
      @assembled_object = object
      @parameters_hash = parameters_hash

      parameters_hash.each do |parameter_name, parameter|
        parameter.name_and_aliases.each do |name_or_alias|
          self.singleton_class.class_eval(<<-RUBY)
            def #{name_or_alias}=(value)
              coerced_value = parameters_hash[:#{parameter_name}].coerce_value(value)
              assembled_object.instance_variable_set(:"@#{parameter_name}", coerced_value)
            end

            def #{name_or_alias}
              assembled_object.instance_variable_get(:"@#{parameter_name}")
            end
          RUBY
        end
      end
    end

    private

    attr_reader :parameters_hash
  end
end
