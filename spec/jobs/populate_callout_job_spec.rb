require 'rails_helper'

RSpec.describe PopulateCalloutJob do
  describe "#perform(callout_population_id)" do

    let(:contact) { create(:contact) }
    let(:callout) { create(:callout) }

    let(:callout_population) {
      create(
        :callout_population,
        :status => CalloutPopulation::STATE_QUEUED,
        :callout => callout
      )
    }

    let(:callout_participation) {
      create(
        :callout_participation,
        :callout => callout,
        :contact => contact
      )
    }

    def setup_scenario
      callout_participation
      subject.perform(callout_population.id)
    end

    def assert_perform!
      expect(callout_population.reload).to be_populated
      expect(callout.contacts).to eq([contact])
    end

    it { assert_perform! }
  end
end
