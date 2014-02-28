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
        instance_variable_set(
          :"@#{param_name}",
          full_options.fetch(param_name) do
            missing_required_params << param_name
          end
        )
      end

      raise(ArgumentError, "missing keywords: #{missing_required_params.join(', ')}") if missing_required_params.any?

      self.class.optional_params.each do |param_name, default_value|
        instance_variable_set(
          :"@#{param_name}",
          full_options.fetch(param_name) do
            default_value
          end
        )
      end
    end
  end
end