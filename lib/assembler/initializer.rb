require "assembler/builder"
require "assembler/parameter"

module Assembler
  module Initializer
    def initialize(options={})
      if self.class.before_assembly_blocks.any?
        self.class.before_assembly_blocks.each do |block|
          instance_eval(&block)
        end
      end

      builder = Assembler::Builder.new(self.class.assembly_parameters_hash, options)

      yield builder if block_given?

      missing_required_parameters = []

      self.class.assembly_parameters.each do |param|
        if_required_and_missing = -> { missing_required_parameters << param.name }

        value = param.value_from(builder.to_h, &if_required_and_missing) 

        instance_variable_set(:"@#{param.name}", value)
      end

      raise(ArgumentError, "missing keywords: #{missing_required_parameters.join(', ')}") if missing_required_parameters.any?

      if self.class.after_assembly_blocks.any?
        self.class.after_assembly_blocks.each do |block|
          instance_eval(&block)
        end
      end
    end
  end
end
