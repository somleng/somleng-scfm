require 'rails_helper'

RSpec.describe "User Events" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  describe "POST '/user/:user_id/user_events'" do
    let(:eventable) { create(:user) }

    let(:account_traits) { { :with_access_token => nil } }
    let(:account_attributes) { {} }
    let(:account) { create(:account, *account_traits.keys, account_attributes) }
    let(:eventable_attributes) { { :account => account } }

    let(:eventable) { create(:user, eventable_attributes) }
    let(:url) { api_user_user_events_path(eventable) }

    it_behaves_like "api_resource_event", :assert_status => false do
      let(:eventable_path) { api_user_path(eventable) }
      let(:event) { "invite" }
    end
  end
end
