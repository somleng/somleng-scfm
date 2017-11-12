RSpec.shared_examples_for "batch_operation" do
  include_examples "has_metadata"

  describe "validations" do
    it {
      is_expected.to validate_presence_of(:type)
    }
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
end
