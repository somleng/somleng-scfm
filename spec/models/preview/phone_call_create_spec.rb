require 'rails_helper'

RSpec.describe Preview::PhoneCallCreate do
  let(:callout_participation_filter_params) { {} }
  let(:callout_filter_params) { {} }

  let(:batch_operation) {
    create(
      :phone_call_create_batch_operation,
      :callout_participation_filter_params => callout_participation_filter_params,
      :callout_filter_params => callout_filter_params
    )
  }

  subject { described_class.new(:previewable => batch_operation) }

  describe "filtering" do
    let(:contact) { create(:contact) }
    let(:callout_factory_params) { { :status => Callout::STATE_RUNNING } }
    let(:callout) { create(:callout, callout_factory_params) }

    let(:callout_participation_factory_params) {
      {
        :metadata => {"foo" => "bar", "bar" => "foo"},
        :contact => contact
      }
    }

    let(:callout_participation) {
      create(
        :callout_participation,
        {:callout => callout}.merge(callout_participation_factory_params)
      )
    }

    let(:callout_filter_params) {
      callout_factory_params.slice(:status)
    }

    let(:callout_participation_filter_params) {
      callout_participation_factory_params.slice(:metadata)
    }

    def setup_scenario
      super
      callout_participation
      create(:callout_participation, callout_participation_filter_params)
    end

    describe "#callout_participations" do
      it { expect(subject.callout_participations).to match_array([callout_participation]) }
    end

    describe "#contacts" do
      it { expect(subject.contacts).to match_array([contact]) }
    end
  end
end
