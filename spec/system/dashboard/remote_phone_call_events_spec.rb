require "rails_helper"

RSpec.describe "Remote Phone Call Events" do
  it "can list all remote phone call events for an account" do
    user = create(:user)
    remote_phone_call_event = create_remote_phone_call_event(account: user.account)
    other_remote_phone_call_event = create(:remote_phone_call_event)

    sign_in(user)
    visit(dashboard_remote_phone_call_events_path)

    within("#button_toolbar") do
      expect(page).to have_link_to_action(:index, key: :remote_phone_call_events)
      expect(page).not_to have_link_to_action(:back)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(remote_phone_call_event)
      expect(page).not_to have_content_tag_for(other_remote_phone_call_event)
      expect(page).to have_content("#")
      expect(page).to have_link(
        remote_phone_call_event.id,
        href: dashboard_remote_phone_call_event_path(remote_phone_call_event)
      )
    end
  end

  it "can list all remote phone call events for a phone call" do
    user = create(:user)
    remote_phone_call_event = create_remote_phone_call_event(account: user.account)
    other_remote_phone_call_event = create_remote_phone_call_event(account: user.account)

    sign_in(user)
    visit(dashboard_phone_call_remote_phone_call_events_path(remote_phone_call_event.phone_call))

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :back,
        href: dashboard_phone_call_path(remote_phone_call_event.phone_call)
      )
    end

    within("#resources") do
      expect(page).to have_content_tag_for(remote_phone_call_event)
      expect(page).not_to have_content_tag_for(other_remote_phone_call_event)
    end
  end

  it "can show a remote phone call event" do
    user = create(:user)
    remote_phone_call_event = create_remote_phone_call_event(account: user.account)

    sign_in(user)
    visit(dashboard_remote_phone_call_event_path(remote_phone_call_event))

    within("#resource") do
      expect(page).to have_content(remote_phone_call_event.id)

      expect(page).to have_link(
        remote_phone_call_event.phone_call_id,
        href: dashboard_phone_call_path(remote_phone_call_event.phone_call_id)
      )

      expect(page).to have_content("#")
      expect(page).to have_content("Phone call")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Details")
    end
  end
end
