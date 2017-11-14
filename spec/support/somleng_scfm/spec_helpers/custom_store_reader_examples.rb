RSpec.shared_examples_for("json_store_reader") do |*args|
  options = args.extract_options!
  default = options[:default]

  args.each do |arg|
    describe "##{arg}" do
      it { expect(subject.public_send(arg)).to eq(default) }
    end
  end
end

RSpec.shared_examples_for("json_store_writer") do |*args|
  options = args.extract_options!
  default = options[:default]

  args.each do |arg|
    describe "##{arg}=(val)" do
      let(:val) { { "foo" => "bar" } }

      it {
        subject.public_send("#{arg}=", val)
        expect(subject.public_send(arg)).to eq(default || val)
      }
    end
  end
end

RSpec.shared_examples_for("json_store_accessor") do |*args|
  options = args.extract_options!

  include_examples("json_store_reader", *args, options)
  include_examples("json_store_writer", *args, options)
end

RSpec.shared_examples_for("hash_store_reader") do |*args|
  args.each do |arg|
    describe "##{arg}" do
      it { expect(subject.public_send(arg)).to eq({}) }
    end
  end
end

RSpec.shared_examples_for("hash_store_accessor") do |*args|
  include_examples("hash_store_reader", *args)
  include_examples("json_store_writer", *args)
end

RSpec.shared_examples_for("boolean_store_accessor") do |*args|
  args.each do |arg|
    describe "##{arg}?" do
      def assert_boolean_accessor!(attribute, value, assertion)
        subject.public_send("#{attribute}=", value)
        expect(subject.public_send("#{attribute}?")).to eq(assertion)
      end

      context "'1'" do
        it { assert_boolean_accessor!(arg, "1", true) }
      end

      context "'true'" do
        it { assert_boolean_accessor!(arg, "true", true) }
      end

      context "'0'" do
        it { assert_boolean_accessor!(arg, "0", false) }
      end

      context "'false'" do
        it { assert_boolean_accessor!(arg, "false", false) }
      end
    end
  end
end

RSpec.shared_examples_for("integer_store_reader") do |*args|
  options = args.extract_options!

  args.each do |arg|
    describe "##{arg}" do
      context "nil" do
        include_examples("json_store_reader", *args, options)
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
