require "assembler/version"
require "assembler/initializer"

module Assembler
  attr_reader :before_assembly_block, :after_assembly_block

  def assemble_from_options(*args)
    assembly_setup do
      options = args.last.is_a?(Hash) ? args.pop : {}
      param_names = args

      param_names.each do |param_name|
        param = Parameter.new(param_name, options)
        assembly_parameters_hash[param.name] = param
      end
    end
  end
  alias_method :assemble_with_options, :assemble_from_options

  def assemble_from(*args)
    assembly_setup do
      optional = args.last.is_a?(Hash) ? args.pop : {}
      required = args

      optional.each { |k,v| assemble_from_options(k, default: v) }
      required.each { |k| assemble_from_options(k) }
    end
  end
  alias_method :assemble_with, :assemble_from

  def assembler_initializer(*args)
    caller_file, caller_line, _ = caller.first.split(':')
    warn "The `assembler_initializer` method is deprecated and will be phased out in version 2.0. Please use `assemble_from` instead. Called from #{caller_file}:#{caller_line}."
    assemble_from(*args)
  end

  def before_assembly(&block)
    assembly_setup do
      @before_assembly_block = block
    end
  end

  def after_assembly(&block)
    assembly_setup do
      @after_assembly_block = block
    end
  end

  def assembly_parameters
    assembly_parameters_hash.values
  end

  def assembly_parameters_hash
    @assembly_parameters_hash ||= {}
  end

  def assembly_setup
    yield
  ensure
    include Assembler::Initializer
    attr_reader *assembly_parameters.map(&:name)
    private *assembly_parameters.map(&:name)
  end
end
