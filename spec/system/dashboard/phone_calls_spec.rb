require "rails_helper"

RSpec.describe "Phone Calls" do
  it "can list all phone calls for an account" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account, status: PhoneCall::STATE_CREATED)
    other_phone_call = create(:phone_call)

    sign_in(user)
    visit(
      dashboard_phone_calls_path(
        q: { status: "created" }
      )
    )

    within("#filters") do
      expect(page).to have_link(
        "All",
        href: dashboard_phone_calls_path
      )

      expect(page).to have_link(
        "Created",
        href: dashboard_phone_calls_path(q: { status: "created" })
      )
    end

    expect(page).to have_title("Phone Calls")

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
      expect(page).to have_content("#")
      expect(page).to have_link(
        phone_call.id.to_s,
        href: dashboard_phone_call_path(phone_call)
      )
    end
  end

  it "can list all phone calls for a callout participation" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_callout_participation_phone_calls_path(phone_call.callout_participation))

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
    end
  end

  it "can list all phone calls for a callout" do
    user = create(:user)
    callout_participation = create_callout_participation(account: user.account)
    phone_call = create_phone_call(
      account: user.account, callout_participation:
    )
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_callout_phone_calls_path(callout_participation.callout))

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
    end
  end

  it "can list all phone calls for a contact" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_contact_phone_calls_path(phone_call.contact))

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
    end
  end

  it "can show a phone call" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_phone_call_path(phone_call))

    within("#related_links") do
      expect(page).to have_link(
        "Phone Call Events",
        href: dashboard_phone_call_remote_phone_call_events_path(phone_call)
      )
    end

    within(".phone_call") do
      expect(page).to have_content(phone_call.id.to_s)

      expect(page).to have_link(
        phone_call.callout_participation_id.to_s,
        href: dashboard_callout_participation_path(phone_call.callout_participation)
      )

      expect(page).to have_link(
        phone_call.callout_id.to_s,
        href: dashboard_callout_path(phone_call.callout_id)
      )

      expect(page).to have_link(
        phone_call.contact_id.to_s,
        href: dashboard_contact_path(phone_call.contact_id)
      )
    end
  end
end
