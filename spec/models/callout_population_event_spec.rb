require 'rails_helper'

RSpec.describe CalloutPopulationEvent do
  let(:eventable_factory) { :callout_population }

  it_behaves_like("resource_event") do
    let(:event) { "queue" }
    let(:asserted_current_status) { CalloutPopulation::STATE_PREVIEW }
    let(:asserted_new_status) { CalloutPopulation::STATE_QUEUED }
  end

  describe "validations" do
    let(:eventable) { create(eventable_factory, :status => status) }
    let(:event) { eventable.aasm.events.map { |event| event.name.to_s }.first }
    subject { described_class.new(:eventable => eventable, :event => event) }

    def assert_validations!
      is_expected.not_to be_valid
      expect(subject.errors[:event]).not_to be_empty
    end

    context "is queued" do
      let(:status) { CalloutPopulation::STATE_QUEUED }
      it { assert_validations! }
    end

    context "is populating" do
      let(:status) { CalloutPopulation::STATE_POPULATING }
      it { assert_validations! }
    end
  end
end
