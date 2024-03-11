require "rails_helper"

RSpec.describe "Recordings" do
  it "list all recordings for an account" do
    recording = create(:recording)
    other_recording = create(:recording)
    user = create(:user, account: recording.account)

    sign_in(user)
    visit(dashboard_recordings_path)

    expect(page).to have_title("Recordings")

    within("#resources") do
      expect(page).to have_content_tag_for(recording)
      expect(page).not_to have_content_tag_for(other_recording)
      expect(page).to have_content("#")
      expect(page).to have_link(
        recording.id.to_s,
        href: dashboard_recording_path(recording)
      )
      expect(page).to have_link(
        recording.id.to_s,
        href: dashboard_recording_path(recording)
      )
    end
  end

  it "shows a recording" do
    recording = create(:recording)
    user = create(:user, account: recording.account)

    sign_in(user)
    visit(dashboard_recording_path(recording))

    within(".recording") do
      expect(page).to have_content(recording.id.to_s)

      expect(page).to have_link(
        recording.phone_call_id.to_s,
        href: dashboard_phone_call_path(recording.phone_call_id)
      )

      expect(page).to have_link(
        recording.contact_id.to_s,
        href: dashboard_contact_path(recording.contact_id)
      )
    end
  end
end
