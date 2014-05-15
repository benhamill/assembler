describe Assembler do
  describe "#assemble_from" do
    context "without parameters" do
      subject do
        Class.new do
          extend Assembler

          assemble_from
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

          assemble_from :foo, bar: 'bar'
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

      it "provides accessors in the builder object" do
        subject.new do |builder|
          builder.foo = :new_foo
          expect(builder.foo).to eq(:new_foo)
        end
      end

      it "pre-fills default values in the builder accessors" do
        subject.new(foo: 'foo') do |builder|
          expect(builder.bar).to eq('bar')
        end
      end

      it "incorporates contructor args in the builder accessors" do
        subject.new(foo: 'foo', bar: 'new_bar') do |builder|
          expect(builder.bar).to eq('new_bar')
        end
      end
    end

    context "when called more than once" do
      subject do
        Class.new do
          extend Assembler

          assemble_from :foo
          assemble_from bar: 'bar'
        end
      end

      it "still takes both arguments" do
        built_object = subject.new do |builder|
          builder.foo = 'baz'
          builder.bar = 'qux'
        end

        expect(built_object.instance_variable_get(:@foo)).to eq('baz')
        expect(built_object.instance_variable_get(:@bar)).to eq('qux')
      end
    end

    context "with mutatable defaults" do
      subject do
        Class.new do
          extend Assembler

          assemble_from favorite_things: []

          attr_reader :favorite_things
        end
      end

      it "doesn't mutate default values in a way that bleeds across instances" do
        first_object = subject.new do |builder|
          builder.favorite_things << :raindrops_on_roses
          builder.favorite_things << :whiskers_on_kittens
          builder.favorite_things << :bright_copper_kettles
          builder.favorite_things << :warm_woolen_mittens
        end

        second_object = subject.new do |builder|
          builder.favorite_things << :brown_paper_packages_tied_up_with_strings
        end

        expect(first_object.favorite_things).to eq([:raindrops_on_roses, :whiskers_on_kittens, :bright_copper_kettles, :warm_woolen_mittens])
        expect(second_object.favorite_things).to eq([:brown_paper_packages_tied_up_with_strings])
      end
    end
  end
end
