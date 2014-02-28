module Assembler
  class Builder
    def initialize(*parameter_names)
      @parameter_names = parameter_names

      parameter_names.each do |parameter_name|
        self.singleton_class.class_eval(<<-RUBY)
          def #{parameter_name}=(value)
            parameters[:#{parameter_name.to_sym}] = value
          end
        RUBY
      end
    end

    def to_h
      parameters
    end

    private

    attr_reader :parameter_names

    def parameters
      @parameters ||= {}
    end
  end
end
