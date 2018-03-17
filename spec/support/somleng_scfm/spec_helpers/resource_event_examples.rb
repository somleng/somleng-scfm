RSpec.shared_examples_for("resource_event") do |options = {}|
  let(:eventable) { create(eventable_factory) }

  describe "validations" do
    describe "eventable" do
      it { is_expected.to validate_presence_of(:eventable) }
    end

    describe "event" do
      subject { described_class.new(:eventable => eventable) }

      it {
        is_expected.to validate_inclusion_of(:event).in_array([event])
      }
    end
  end

  describe "#save" do
    subject { described_class.new(:eventable => eventable, :event => event) }

    context "invalid" do
      let(:event) { "invalid" }

      it {
        expect(subject.save).to eq(false)
        expect(subject.eventable.status).to eq(asserted_current_status.to_s) if options[:assert_status] != false
      }
    end

    context "valid" do
      it {
        expect(subject.save).to eq(true)
        expect(subject.eventable.status).to eq(asserted_new_status.to_s) if options[:assert_status] != false
      }
    end
  end
end
