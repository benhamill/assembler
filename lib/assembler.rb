require "assembler/version"
require "assembler/initializer"

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
end
