RSpec.shared_examples_for("json_attr_reader") do |*args|
  args.each do |arg|
    describe "##{arg}" do
      it { expect(subject.public_send(arg)).to eq(nil) }
    end
  end
end

RSpec.shared_examples_for("json_attr_writer") do |*args|
  args.each do |arg|
    describe "##{arg}=(val)" do
      let(:val) { { "foo" => "bar" } }

      it {
        subject.public_send("#{arg}=", val)
        expect(subject.public_send(arg)).to eq(val)
      }
    end
  end
end

RSpec.shared_examples_for("json_attr_accessor") do |*args|
  include_examples("json_attr_reader", *args)
  include_examples("json_attr_writer", *args)
end

RSpec.shared_examples_for("hash_attr_reader") do |*args|
  args.each do |arg|
    describe "##{arg}" do
      it { expect(subject.public_send(arg)).to eq({}) }
    end
  end
end

RSpec.shared_examples_for("hash_attr_accessor") do |*args|
  include_examples("hash_attr_reader", *args)
  include_examples("json_attr_writer", *args)
end

RSpec.shared_examples_for("integer_attr_reader") do |*args|
  include_examples("json_attr_reader", *args)

  args.each do |arg|
    describe "##{arg}" do
      context "nil" do
        include_examples("json_attr_reader", arg)
      end

      context "5" do
        it {
          subject.public_send("#{arg}=", "5")
          expect(subject.public_send(arg)).to eq(5)
        }
      end
    end
  end
end
