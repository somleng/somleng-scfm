require 'rails_helper'

RSpec.describe "POST '/callouts/:callout_id/callout_events'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:eventable) { create(:callout) }
  let(:url) { api_callout_callout_events_path(eventable) }

  it_behaves_like "api_resource_event" do
    let(:eventable_path) { api_callout_path(eventable) }
    let(:asserted_new_status) { "running" }
    let(:event) { "start" }
  end
end

