describe Assembler do
  describe "#assembler_method" do
    context "with no context" do
      let(:klass) do
        Class.new do
          extend Assembler

          assemble_from output: nil

          assembler_method :b_method do |builder|
            builder.output = :builder_output
          end
        end
      end

      subject { klass.new {|b| b.b_method } }
    end

    context "with default value" do
      let(:klass) do
        Class.new do
          extend Assembler

          assemble_from :no_default, default: :default

          assembler_method :b_method do |builder|
            builder.no_default = builder.default
          end
        end
      end

      subject { klass.new {|b| b.b_method } }
    end

    context "with coerced values" do
      let(:klass) do
        Class.new do
          extend Assembler

          assemble_from_options :output, coerce: :to_i

          assembler_method :b_method do |builder|
            builder.output = '10'
          end
        end
      end

      subject { klass.new {|b| b.b_method } }
    end

    context "with required values" do
      let(:klass) do
        Class.new do
          extend Assembler

          assemble_from_options :output

          assembler_method :b_method do |builder|
            builder.output = '10'
          end
        end
      end

      subject { klass.new {|b| b.b_method } }
    end
  end
end
