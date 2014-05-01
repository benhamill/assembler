require "assembler/builder"
require "assembler/parameter"

module Assembler
  module Initializer
    def initialize(options={})
      self.class.before_assembly_blocks.each do |block|
        instance_eval(&block)
      end

      builder = Assembler::Builder.new(self, self.class.assembly_parameters_hash)
      methods = self.class.assembly_parameters.flat_map(&:name_and_aliases)

      self.class.assembly_parameters.select(&:has_default?).each do |param|
        builder.send("#{param.name}=", param.default)
      end

      options.each do |param_name, value|
        builder.send("#{param_name.to_sym}=", value) if methods.include?(param_name.to_sym)
      end

      yield builder if block_given?

      self.class.after_assembly_blocks.each do |block|
        instance_eval(&block)
      end

      missing_required_parameters = self.class.assembly_parameters.
        reject { |param| param.has_default? }.
        reject { |param| instance_variable_defined?(:"@#{param.name}") }

      if missing_required_parameters.any?
        raise(ArgumentError, "missing keywords: #{missing_required_parameters.map(&:name).join(', ')}") 
      end
    end
  end
end
