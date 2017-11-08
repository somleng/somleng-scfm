require 'rails_helper'

RSpec.describe CalloutPopulation do
  let(:factory) { :callout_population }
  include_examples "has_metadata"

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
        assert_broadcasted!(:callout_population_queued) { subject.queue! }
      }

      it { assert_transitions! }
    end
  end

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:callout)
    end

    it { assert_associations! }
  end

  describe "#contact_filter_params" do
    it { expect(subject.contact_filter_params).to eq({}) }
  end
end
