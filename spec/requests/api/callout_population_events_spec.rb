require 'rails_helper'

RSpec.describe "POST '/api/callout_populations/:id/events'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:eventable) { create(:callout_population) }
  let(:url) { api_callout_population_callout_population_events_path(eventable) }

  it_behaves_like "api_resource_event" do
    let(:eventable_path) { api_callout_population_path(eventable) }
    let(:asserted_new_status) { "queued" }
    let(:event) { "queue" }
  end
end
