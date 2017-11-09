require 'rails_helper'

RSpec.describe CalloutPopulationObserver do
  describe "#callout_population_queued(callout_population)" do
    let(:callout_population) { create(:callout_population, :status => CalloutPopulation::STATE_QUEUED) }
    let(:enqueued_job) { enqueued_jobs.first }

    def setup_scenario
      subject.callout_population_queued(callout_population)
    end

    it {
      expect(enqueued_job[:job]).to eq(PopulateCalloutJob)
      expect(enqueued_job[:args]).to eq([callout_population.id])
    }
  end
end

