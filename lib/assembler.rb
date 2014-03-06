require "assembler/version"
require "assembler/initializer"

module Assembler
  attr_reader :all_param_names

  def assemble_from(*required, **optional)
    include Assembler::Initializer

    required_params.push(*required)
    optional_params.merge!(optional)

    @all_param_names = (required_params + optional_params.keys).map(&:to_sym)
    attr_reader *all_param_names
    private *all_param_names
  end
  alias_method :assemble_with, :assemble_from

  def assembler_initializer(*args)
    caller_file, caller_line, _ = caller.first.split(':')
    warn "The `assembler_initializer` method is deprecated and will be phased out in version 2.0. Please use `assemble_from` instead. Called from #{caller_file}:#{caller_line}."
    assemble_from(*args)
  end

  def required_params
    @required_params ||= []
  end

  def optional_params
    @optional_params ||= {}
  end
end
