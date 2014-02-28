require "assembler/version"

module Assembler
  attr_reader :required_params, :optional_params

  def assembler_initializer(*required, **optional)
    self.include Assembler::Initializer

    @required_params = required
    @optional_params = optional

    reader_methods = (required + optional.keys).map(&:to_sym)

    attr_reader *reader_methods
    private *reader_methods
  end

  module Initializer
    def initialize(options={})
      missing_required_params = []

      self.class.required_params.each do |param_name|
        instance_variable_set(
          :"@#{param_name}",
          options.fetch(param_name.to_sym) do
            options.fetch(param_name.to_s) do
              missing_required_params << param_name
            end
          end
        )
      end

      raise(ArgumentError, "missing keywords: #{missing_required_params.join(', ')}") if missing_required_params.any?

      self.class.optional_params.each do |param_name, default_value|
        instance_variable_set(
          :"@#{param_name}",
          options.fetch(param_name.to_sym) do
            options.fetch(param_name.to_s) do
              default_value
            end
          end
        )
      end
    end
  end
end
