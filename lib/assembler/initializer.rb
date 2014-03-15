require "assembler/builder"
require "assembler/parameter"
require "assembler/parameters"

module Assembler
  module Initializer
    def initialize(options={})
      instance_eval(&self.class.before_block) if self.class.before_block

      builder = Assembler::Builder.new(*self.class.all_param_names)

      yield builder if block_given?

      @full_options = Assembler::Parameters.new(options.merge(builder.to_h))

      missing_required_params = []

      self.class.required_params.each do |param|
        remember_value_or(param.name) { missing_required_params << param.name }
      end

      self.class.optional_params.each do |param|
        remember_value_or(param.name) { param.default }
      end

      raise(ArgumentError, "missing keywords: #{missing_required_params.join(', ')}") if missing_required_params.any?

      instance_eval(&self.class.after_block) if self.class.after_block
    end

    private

    attr_reader :full_options

    def remember_value_or(param_name, &block)
      instance_variable_set(
        :"@#{param_name}",
        self.class.params[param_name].coerce_value do
          full_options.fetch(param_name) do
            block.call
          end
        end
      )
    end
  end
end
