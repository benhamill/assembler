require 'spec_helper'

describe Assembler do
  describe "#before_assembly" do
    context "with no other assembler helpers called" do
      let(:klass) do
        Class.new do
          extend Assembler

          before_assembly do
            @before = true
          end

          attr_reader :before
        end
      end

      subject { klass.new }

      it "calls the before block" do
        expect(subject.before).to be_true
      end
    end

    context "with a more complex declaration" do
      let(:klass) do
        Class.new do
          extend Assembler

          assemble_with :middle

          before_assembly do
            @before = true
            @middle = 'before'
          end

          attr_reader :before, :middle
        end
      end

      subject do
        klass.new(middle: 'middle')
      end

      it "calls the before block" do
        expect(subject.before).to be_true
      end

      it "calls the block before running the rest of the initializer" do
        expect(subject.middle).to eq('middle')
      end
    end
  end
end
