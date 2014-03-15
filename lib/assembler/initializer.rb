require "assembler/builder"
require "assembler/parameter"

module Assembler
  module Initializer
    def initialize(options={})
      instance_eval(&self.class.before_block) if self.class.before_block

      builder = Assembler::Builder.new(*self.class.params.flat_map(&:name_and_aliases))

      yield builder if block_given?

      full_options = options.merge(builder.to_h)

      missing_required_params = []

      self.class.params.each do |param|
        if_missing_required = -> { missing_required_params << param.name }

        value = param.value_from(full_options, &if_missing_required) 

        instance_variable_set(:"@#{param.name}", value)
      end

      raise(ArgumentError, "missing keywords: #{missing_required_params.join(', ')}") if missing_required_params.any?

      instance_eval(&self.class.after_block) if self.class.after_block
    end
  end
end
