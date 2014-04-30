require "assembler/builder"
require "assembler/parameter"

module Assembler
  module Initializer
    def initialize(options={})
      # Set default values
      self.class.assembly_parameters.select(&:has_default?).each do |param|
        send("#{param.name}=", param.default)
      end

      # Execute before blocks
      if self.class.before_assembly_blocks.any?
        self.class.before_assembly_blocks.each do |block|
          instance_eval(&block)
        end
      end

      # Set values from method-call syntax
      defined_names = self.class.assembly_parameters.flat_map(&:name_and_aliases).uniq
      options.each do |key, value|
        send("#{key}=", value) if defined_names.include?(key.to_sym)
      end

      # Set values from block syntax
      yield Builder.new(self) if block_given?

      # Validate required values were set
      missing_required_parameters = []
      self.class.assembly_parameters.each do |param|
        if !param.has_default? && !instance_variable_defined?(param.ivar_name)
          missing_required_parameters << param.name
        end
      end
      raise(ArgumentError, "missing keywords: #{missing_required_parameters.join(', ')}") if missing_required_parameters.any?

      # Execute after blocks
      if self.class.after_assembly_blocks.any?
        self.class.after_assembly_blocks.each do |block|
          instance_eval(&block)
        end
      end
    end
  end
end
