require "assembler/builder"
require "assembler/parameters"

module Assembler
  module Initializer
    def initialize(options={})
      instance_eval(&self.class.before_block) if self.class.before_block

      builder = Assembler::Builder.new(*self.class.all_param_names)

      yield builder if block_given?

      @full_options = Assembler::Parameters.new(options.merge(builder.to_h))

      missing_required_params = []

      self.class.required_params.each do |param_name|
        remember_value_or(param_name) { missing_required_params << param_name }
      end

      self.class.optional_params.each do |param_name, default_value|
        remember_value_or(param_name) { default_value }
      end

      raise(ArgumentError, "missing keywords: #{missing_required_params.join(', ')}") if missing_required_params.any?

      instance_eval(&self.class.after_block) if self.class.after_block
    end

    private

    attr_reader :full_options

    def remember_value_or(param_name, &block)
      instance_variable_set(
        :"@#{param_name}",
        full_options.fetch(param_name) do
          block.call
        end
      )
    end
  end
end
