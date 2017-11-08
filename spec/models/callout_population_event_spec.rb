require 'rails_helper'

RSpec.describe CalloutPopulationEvent do
  let(:eventable_factory) { :callout_population }

  it_behaves_like("resource_event") do
    let(:event) { "queue" }
    let(:asserted_current_status) { CalloutPopulation::STATE_PREVIEW }
    let(:asserted_new_status) { CalloutPopulation::STATE_QUEUED }
  end
end
