require "assembler/builder"
require "assembler/parameters"

module Assembler
  module Initializer
    def initialize(options={})
      builder = Assembler::Builder.new(*self.class.all_param_names)

      yield builder if block_given?

      full_options = Assembler::Parameters.new(options.merge(builder.to_h))

      missing_required_params = []

      self.class.required_params.each do |param_name|
        remember_value_or(full_options, param_name) do
          missing_required_params << param_name
        end
      end

      raise(ArgumentError, "missing keywords: #{missing_required_params.join(', ')}") if missing_required_params.any?

      self.class.optional_params.each do |param_name, default_value|
        remember_value_or(full_options, param_name) do
          default_value
        end
      end
    end

    private

    def remember_value_or(params, param_name, &block)
      instance_variable_set(
        :"@#{param_name}",
        params.fetch(param_name) do
          block.call
        end
      )
    end
  end
end
