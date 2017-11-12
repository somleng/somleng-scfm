RSpec.shared_examples_for("hash_attr_accessor") do |*args|
  args.each do |arg|
    describe "##{arg}" do
      it { expect(subject.public_send(arg)).to eq({}) }
    end

    describe "##{arg}=(val)" do
      let(:val) { { "foo" => "bar" } }

      it {
        subject.public_send("#{arg}=", val)
        expect(subject.public_send(arg)).to eq(val)
      }
    end
  end
end
