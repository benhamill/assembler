require 'spec_helper'

describe Assembler do
  describe "#assemble_from_options" do
    context "without parameters" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options
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

    context "with no default parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, :bar
        end
      end

      it "barfs from missing required parameters" do
        expect { subject.new }.to raise_error(ArgumentError)
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
        built_object = subject.new(foo: 'foo', bar: 'bar', baz: 'baz')

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

    context "with default parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, :bar, default: 'default'
        end
      end

      it "uses default values for missing parameters (method arguments)" do
        built_object = subject.new

        expect(built_object.instance_variable_get(:@foo)).to eq('default')
        expect(built_object.instance_variable_get(:@bar)).to eq('default')
      end

      it "uses default values for missing parameters (block)" do
        built_object = subject.new do |builder|
        end

        expect(built_object.instance_variable_get(:@foo)).to eq('default')
        expect(built_object.instance_variable_get(:@bar)).to eq('default')
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
        built_object = subject.new(baz: 'baz')

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

    context "with coerce parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, coerce: :to_set
        end
      end

      it "sends parameter value to constructor argument"
      it "assigns the output of the coercion"
    end

    context "with singular alias parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, aliases: :bar
        end
      end

      it "creates an alias"
    end

    context "with enumerable alias parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, aliases: [:bar, :baz]
        end
      end

      it "creates aliases"
    end

    context "when called more than once for the same key" do
      subject do
        Class.new do
          extend Assembler

          assemble_from :foo
          assemble_from bar: 'bar'
        end
      end

      it "re-writes default"
      it "re-writes aliases"
      it "re-writes coercions"
    end
  end
end

