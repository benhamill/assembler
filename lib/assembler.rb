require "assembler/version"

module Assembler
  attr_reader :required_params, :optional_params, :all_param_names

  def assembler_initializer(*required, **optional)
    self.include Assembler::Initializer

    @required_params = required
    @optional_params = optional
    @all_param_names = (required + optional.keys).map(&:to_sym)

    attr_reader *all_param_names
    private *all_param_names
  end

  module Initializer
    def initialize(options={})
      builder = Assembler::Builder.new(*self.class.all_param_names)

      yield builder if block_given?

      full_options = options.merge(builder.to_h)

      missing_required_params = []

      self.class.required_params.each do |param_name|
        instance_variable_set(
          :"@#{param_name}",
          full_options.fetch(param_name.to_sym) do
            full_options.fetch(param_name.to_s) do
              missing_required_params << param_name
            end
          end
        )
      end

      raise(ArgumentError, "missing keywords: #{missing_required_params.join(', ')}") if missing_required_params.any?

      self.class.optional_params.each do |param_name, default_value|
        instance_variable_set(
          :"@#{param_name}",
          full_options.fetch(param_name.to_sym) do
            full_options.fetch(param_name.to_s) do
              default_value
            end
          end
        )
      end
    end
  end

  class Builder
    def initialize(*parameter_names)
      @parameter_names = parameter_names

      parameter_names.each do |parameter_name|
        self.singleton_class.class_eval(<<-RUBY)
          def #{parameter_name}=(value)
            parameters[:#{parameter_name.to_sym}] = value
          end
        RUBY
      end
    end

    def to_h
      parameters
    end

    private

    attr_reader :parameter_names

    def parameters
      @parameters ||= {}
    end
  end
end
