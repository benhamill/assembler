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

      it "doesn't have methods on the builder object" do
        subject.new do |builder|
          expect(builder).to_not respond_to(:foo)
        end
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

      it "uses default values for missing parameters (method arguments)" do
        built_object = subject.new(foo: 'foo')

        expect(built_object.instance_variable_get(:@bar)).to eq('bar')
      end

      it "uses default values for missing parameters (block)" do
        built_object = subject.new do |builder|
          builder.foo = 'foo'
        end

        expect(built_object.instance_variable_get(:@bar)).to eq('bar')
      end

      it "holds onto the parameters (method arguments)" do
        built_object = subject.new(foo: 'baz', bar: 'qux')

        expect(built_object.instance_variable_get(:@foo)).to eq('baz')
        expect(built_object.instance_variable_get(:@bar)).to eq('qux')
      end

      it "holds onto the parameters (block)" do
        built_object = subject.new do |builder|
          builder.foo = 'baz'
          builder.bar = 'qux'
        end

        expect(built_object.instance_variable_get(:@foo)).to eq('baz')
        expect(built_object.instance_variable_get(:@bar)).to eq('qux')
      end

      it "ignores un-named parameters in method arguments" do
        built_object = subject.new(foo: 'bar', baz: 'baz')

        expect(built_object.instance_variables).to_not include(:@baz)
      end

      it "doesn't create builder methods for un-named parameters" do
        expect {
          subject.new do |builder|
            builder.baz = 'baz'
          end
        }.to raise_error(NoMethodError)
      end
    end
  end
end
