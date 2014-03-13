require 'spec_helper'

describe Assembler do
  describe "#after_assembly" do
    context "with no other assembler helpers called" do
      let(:klass) do
        Class.new do
          extend Assembler

          after_assembly do
            @after = true
          end

          attr_reader :after
        end
      end

      subject { klass.new }

      it "calls the after block" do
        expect(subject.after).to be_true
      end
    end

    context "with a more complex declaration" do
      let(:klass) do
        Class.new do
          extend Assembler

          assemble_with middle: 'middle'

          after_assembly do
            a_private_method
            @after = true
            @middle = 'after'
          end

          attr_reader :after, :middle

          private

          def a_private_method
            "Shhhhhhh! it's a secret!"
          end
        end
      end

      subject do
        klass.new
      end

      it "calls the after block" do
        expect(subject.after).to be_true
      end

      it "calls the block after running the rest of the initializer" do
        expect(subject.middle).to eq('after')
      end

      it "allows access to private methods" do
        expect { klass.new }.to_not raise_error
      end
    end
  end
end
