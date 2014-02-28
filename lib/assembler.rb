require "assembler/version"

module Assembler
  def assembler_initializer(*required, **optional)
    self.include Assembler::Initializer
  end

  module Initializer
    def initialize(options={})
    end
  end
end
