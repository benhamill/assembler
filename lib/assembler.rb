require "assembler/version"
require "assembler/initializer"

module Assembler
  attr_writer :required_params, :optional_params
  attr_reader :before_block, :after_block

  def assemble_from_options(*args)
    ensure_setup do
      options = args.last.is_a?(Hash) ? args.pop : {}
      param_names = args

      if options.has_key?(:default)
        param_names.each do |param_name|
          self.optional_params = optional_params.merge(param_name => options[:default])
        end
      else
        self.required_params += param_names
      end
    end
  end
  alias_method :assemble_with_options, :assemble_from_options

  def assemble_from(*args)
    ensure_setup do
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
    ensure_setup do
      @before_block = block
    end
  end

  def after_assembly(&block)
    ensure_setup do
      @after_block = block
    end
  end

  def required_params
    @required_params ||= []
  end

  def optional_params
    @optional_params ||= {}
  end

  def all_param_names
    (required_params + optional_params.keys).map(&:to_sym)
  end

  def ensure_setup
    yield
  ensure
    include Assembler::Initializer
    attr_reader *all_param_names
    private *all_param_names
  end
end
