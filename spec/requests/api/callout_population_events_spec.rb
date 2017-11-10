require 'rails_helper'

RSpec.describe "POST '/api/callout_populations/:id/events'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:factory_attributes) { {} }
  let(:callout_population) { create(:callout_population, factory_attributes) }
  let(:eventable) { callout_population }
  let(:url) { api_callout_population_callout_population_events_path(eventable) }

  it_behaves_like "api_resource_event" do
    let(:eventable_path) { api_callout_population_path(eventable) }
    let(:asserted_new_status) { "queued" }
    let(:event) { "queue" }
  end

  context "queuing" do
    let(:body) { {:event => event} }
    let(:contact) { create(:contact) }

    let(:factory_attributes) {
      {
        :status => status
      }
    }

    def setup_scenario
      super
      contact
      perform_enqueued_jobs { do_request(:post, url, body) }
    end

    def assert_populated!
      expect(callout_population.reload).to be_populated
      expect(callout_population.contacts).to match_array([contact])
    end

    def assert_invalid!
      expect(response.code).to eq("422")
    end

    context "event=queue" do
      let(:event) { "queue" }

      context "invalid request" do
        let(:status) { CalloutPopulation::STATE_POPULATED }
        it { assert_invalid! }
      end

      context "valid request" do
        let(:status) { CalloutPopulation::STATE_PREVIEW }
        it { assert_populated! }
      end
    end

    context "event=requeue" do
      let(:status) { CalloutPopulation::STATE_POPULATED }
      let(:event) { "requeue" }
      it { assert_populated! }
    end
  end
end
