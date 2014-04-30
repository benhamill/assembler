module Assembler
  class Builder
    def initialize(proxy_object)
      @proxy_object = proxy_object
    end

    private

    attr_reader :proxy_object

    def method_missing(meth, *args, &block)
      proxy_object.send(meth, *args, &block)
    end
  end
end
