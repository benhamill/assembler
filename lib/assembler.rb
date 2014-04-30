require "assembler/version"
require "assembler/initializer"

module Assembler
  def assemble_from_options(*args)
    include Assembler::Initializer

    options = args.last.is_a?(Hash) ? args.pop : {}
    param_names = args

    param_names.each do |param_name|
      param = Parameter.new(param_name, options)
      assembly_parameters_hash[param.name] = param

      param.name_and_aliases.each do |name_or_alias|
        define_method("#{name_or_alias}=") do |value|
          coerced_value = param.coerce_value(value)
          instance_variable_set(param.ivar_name, coerced_value)
        end
        private "#{name_or_alias}=".to_sym

        define_method(name_or_alias) do
          instance_variable_get(param.ivar_name)
        end
        private name_or_alias.to_sym
      end
    end
  end
  alias_method :assemble_with_options, :assemble_from_options

  def assemble_from(*args)
    include Assembler::Initializer

    optional = args.last.is_a?(Hash) ? args.pop : {}
    required = args

    optional.each { |k,v| assemble_from_options(k, default: v) }
    required.each { |k| assemble_from_options(k) }
  end
  alias_method :assemble_with, :assemble_from

  def assembler_initializer(*args)
    caller_file, caller_line, _ = caller.first.split(':')
    warn "The `assembler_initializer` method is deprecated and will be phased out in version 2.0. Please use `assemble_from` instead. Called from #{caller_file}:#{caller_line}."
    assemble_from(*args)
  end

  def before_assembly(&block)
    include Assembler::Initializer

    before_assembly_blocks << block
  end

  def before_assembly_blocks
    @before_assembly_blocks ||= []
  end

  def after_assembly(&block)
    include Assembler::Initializer
    
    after_assembly_blocks << block
  end

  def after_assembly_blocks
    @after_assembly_blocks ||= []
  end

  def assembly_parameters
    assembly_parameters_hash.values
  end

  def assembly_parameters_hash
    @assembly_parameters_hash ||= {}
  end
end
