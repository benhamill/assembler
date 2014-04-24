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
          assemble_from_options :baz, :qux, default: nil
        end
      end

      it "uses default values for missing parameters (method arguments)" do
        built_object = subject.new

        expect(built_object.instance_variable_get(:@foo)).to eq('default')
        expect(built_object.instance_variable_get(:@bar)).to eq('default')
        expect(built_object.instance_variable_get(:@baz)).to eq(nil)
        expect(built_object.instance_variable_get(:@qux)).to eq(nil)
      end

      it "uses default values for missing parameters (block)" do
        built_object = subject.new do |builder|
        end

        expect(built_object.instance_variable_get(:@foo)).to eq('default')
        expect(built_object.instance_variable_get(:@bar)).to eq('default')
        expect(built_object.instance_variable_get(:@baz)).to eq(nil)
        expect(built_object.instance_variable_get(:@qux)).to eq(nil)
      end

      it "holds onto the parameters (method arguments)" do
        built_object = subject.new(foo: 'foo', bar: 'bar', baz: 'baz', qux: 'qux')

        expect(built_object.instance_variable_get(:@foo)).to eq('foo')
        expect(built_object.instance_variable_get(:@bar)).to eq('bar')
        expect(built_object.instance_variable_get(:@baz)).to eq('baz')
        expect(built_object.instance_variable_get(:@qux)).to eq('qux')
      end

      it "holds onto the parameters (block)" do
        built_object = subject.new do |builder|
          builder.foo = 'foo'
          builder.bar = 'bar'
          builder.baz = 'baz'
          builder.qux = 'qux'
        end

        expect(built_object.instance_variable_get(:@foo)).to eq('foo')
        expect(built_object.instance_variable_get(:@bar)).to eq('bar')
        expect(built_object.instance_variable_get(:@baz)).to eq('baz')
        expect(built_object.instance_variable_get(:@qux)).to eq('qux')
      end

      it "ignores un-named parameters in method arguments" do
        built_object = subject.new(nope: 'nope')

        expect(built_object.instance_variables).to_not include(:@nope)
      end

      it "doesn't create builder methods for un-named parameters" do
        expect {
          subject.new do |builder|
            builder.nope = 'nope'
          end
        }.to raise_error(NoMethodError)
      end
    end

    context "with symbol coerce parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, coerce: :to_set
        end
      end

      let(:argument) { double('argument', to_set: Set.new([:coerced])) }

      it "sends parameter value to constructor argument (method arguments)" do
        expect(argument).to receive(:to_set).and_return(Set.new([:coerced]))
        subject.new(foo: argument)
      end

      it "assigns the output of the coercion (method arguments)" do
        built_object = subject.new(foo: argument)

        expect(built_object.instance_variable_get(:@foo)).to eq(Set.new([:coerced]))
      end
      
      it "sends parameter value to constructor argument (block)" do
        expect(argument).to receive(:to_set).and_return(Set.new([:coerced]))
        subject.new { |b| b.foo = argument }
      end

      it "assigns the output of the coercion (block)" do
        built_object = subject.new { |b| b.foo = argument }

        expect(built_object.instance_variable_get(:@foo)).to eq(Set.new([:coerced]))
      end
    end

    context "with callable coerce parameter" do
      subject do
        callable = double('callable')
        allow(callable).to receive(:call) do |s|
          [s, :called]
        end

        Class.new do
          extend Assembler

          assemble_from_options :lambda, default: nil, coerce: ->(s) { [s, :called] }
          assemble_from_options :proc, default: nil, coerce: Proc.new { |s| [s, :called] }
          assemble_from_options :callable, default: nil, coerce: callable
        end
      end

      let(:argument) { double('argument') }

      it "assigns the output of the coercion (method arguments)" do
        expect(subject.new(:lambda => :original).instance_variable_get(:@lambda)).to eq([:original, :called])
        expect(subject.new(:proc => :original).instance_variable_get(:@proc)).to eq([:original, :called])
        expect(subject.new(:callable => :original).instance_variable_get(:@callable)).to eq([:original, :called])
      end

      it "assigns the output of the coercion (block)" do
        expect(subject.new {|b| b.lambda = :original}.instance_variable_get(:@lambda)).to eq([:original, :called])
        expect(subject.new {|b| b.proc = :original}.instance_variable_get(:@proc)).to eq([:original, :called])
        expect(subject.new {|b| b.callable = :original}.instance_variable_get(:@callable)).to eq([:original, :called])
      end
    end

    context "with singular alias parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, :alias => :bar
        end
      end

      it "creates an alias" do
        expect(subject.new(bar: :bar).instance_variable_get(:@foo)).to eq(:bar)
      end
    end

    context "with enumerable alias parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, :alias => [:bar, :baz]
        end
      end

      it "creates aliases" do
        expect(subject.new(bar: :bar).instance_variable_get(:@foo)).to eq(:bar)
        expect(subject.new(baz: :baz).instance_variable_get(:@foo)).to eq(:baz)
      end
    end

    context "with singular aliases parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, aliases: :bar
        end
      end

      it "creates an alias" do
        expect(subject.new(bar: :bar).instance_variable_get(:@foo)).to eq(:bar)
      end
    end

    context "with enumerable aliases parameter" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo, aliases: [:bar, :baz]
        end
      end

      it "creates aliases" do
        expect(subject.new(bar: :bar).instance_variable_get(:@foo)).to eq(:bar)
        expect(subject.new(baz: :baz).instance_variable_get(:@foo)).to eq(:baz)
      end
    end

    context "when called more than once for the same key" do
      subject do
        Class.new do
          extend Assembler

          assemble_from_options :foo
          assemble_from_options :foo, default: :foo, coerce: :to_sym, aliases: [:bar]
        end
      end

      it "re-writes default" do
        expect(subject.new.instance_variable_get(:@foo)).to eq(:foo)
      end

      it "re-writes aliases (method)" do
        expect(subject.new(bar: :bar).instance_variable_get(:@foo)).to eq(:bar)
      end

      it "re-writes aliases (block)" do
        expect(subject.new { |s| s.bar = :bar}.instance_variable_get(:@foo)).to eq(:bar)
      end

      it "re-writes coercions (method)" do
        expect(subject.new(foo: 'foo').instance_variable_get(:@foo)).to eq(:foo)
      end

      it "re-writes coercions (block)" do
        expect(subject.new { |s| s.foo = 'foo'}.instance_variable_get(:@foo)).to eq(:foo)
      end
    end
  end
end

