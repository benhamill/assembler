require 'spec_helper'
require 'assembler'

describe Assembler do
  describe "#assembler_initializer" do
    context "without parameters" do
      subject do
        Class.new do
          extend Assembler

          assembler_initializer
        end
      end

      it "throws away all input parameters (method arguments)" do
        built_object = subject.new(foo: 'foo', bar: 'bar')

        expect(built_object.instance_variables).to_not include(:@foo, :@bar)
      end
    end

    context "with a mix of required and optional parameters" do
      subject do
        Class.new do
          extend Assembler

          assembler_initializer :foo, bar: 'bar'
        end
      end

      it "barfs from missing required parameters" do
        expect { subject.new }.to raise_error(ArgumentError)
      end

      it "uses default values for missing parameters" do
        built_object = subject.new(foo: 'foo')

        expect(subject.instance_variable_get(:@bar)).to eq('bar')
      end

      it "holds onto the parameters" do
        built_object = subject.new(foo: 'baz', bar: 'qux')

        expect(subject.instance_variable_get(:@foo)).to eq('baz')
        expect(subject.instance_variable_get(:@bar)).to eq('qux')
      end

      it "ignores un-named parameters" do
        built_object = subject.new(baz: 'baz')

        expect(built_object.instance_variables).to_not include(:@baz)
      end
    end
  end
end
