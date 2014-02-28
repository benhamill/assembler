module Assembler
  class Parameters
    def initialize(params={})
      @params = params
    end

    def fetch(key, &block)
      params.fetch(key.to_sym) do
        params.fetch(key.to_s) do
          block.call
        end
      end
    end

    private

    attr_reader :params
  end
end
