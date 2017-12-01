RSpec.shared_examples_for "batch_operation" do
  include_examples "has_metadata"

  describe "validations" do
    subject { build(factory) }

    def assert_validations!
      is_expected.to validate_presence_of(:type)
      is_expected.not_to allow_value("foo").for(:parameters)
      is_expected.to allow_value({"foo" => "bar"}).for(:parameters)
      subject.parameters = nil
      is_expected.not_to be_valid
      expect(subject.errors[:parameters]).not_to be_empty
    end

    it { assert_validations! }
  end

  describe "state_machine" do
    subject { create(factory, factory_attributes) }

    def factory_attributes
      {:status => current_status}
    end

    def assert_transitions!
      is_expected.to transition_from(current_status).to(asserted_new_status).on_event(event)
    end

    describe "#queue!" do
      let(:current_status) { :preview }
      let(:asserted_new_status) { :queued }
      let(:event) { :queue }

      it("should broadcast") {
        assert_broadcasted!(:batch_operation_queued) { subject.queue! }
      }

      it { assert_transitions! }
    end

    describe "#start!" do
      let(:current_status) { :queued }
      let(:asserted_new_status) { :running }
      let(:event) { :start }

      it { assert_transitions! }
    end

    describe "#finish!" do
      let(:current_status) { :running }
      let(:asserted_new_status) { :finished }
      let(:event) { :finish }

      it { assert_transitions! }
    end

    describe "#requeue!" do
      let(:current_status) { :finished }
      let(:asserted_new_status) { :queued }
      let(:event) { :requeue }

      it("should broadcast") {
        assert_broadcasted!(:batch_operation_queued) { subject.requeue! }
      }

      it { assert_transitions! }
    end
  end

  describe "#to_json" do
    subject { create(factory) }
    let(:json) { subject.to_json }
    let(:parsed_json) { JSON.parse(json) }

    def assert_json!
      expect(parsed_json).to have_key("type")
    end

    it { assert_json! }
  end
end
