require "rails_helper"

RSpec.describe "Phone Calls" do
  it "can list all phone calls for an account" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)
    other_phone_call = create(:phone_call)

    sign_in(user)
    visit(dashboard_phone_calls_path)

    within("#button_toolbar") do
      expect(page).to have_link_to_action(:index, key: :phone_calls)
      expect(page).not_to have_link_to_action(:back)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
      expect(page).to have_content("#")
      expect(page).to have_link(
        phone_call.id,
        href: dashboard_phone_call_path(phone_call)
      )
      expect(page).to have_content("Phone Number")
      expect(page).to have_content("Direction")
      expect(page).to have_content("Status")
      expect(page).to have_content("Created At")
    end
  end

  it "can list all phone calls for a callout participation" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_callout_participation_phone_calls_path(phone_call.callout_participation))

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :back,
        href: dashboard_callout_participation_path(phone_call.callout_participation)
      )
    end

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
    end
  end

  it "can list all phone calls for a callout" do
    user = create(:user)
    callout_participation = create_callout_participation(account: user.account)
    phone_call = create_phone_call(
      account: user.account, callout_participation: callout_participation
    )
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_callout_phone_calls_path(callout_participation.callout))

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :back,
        href: dashboard_callout_path(callout_participation.callout)
      )
    end

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

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :back,
        href: dashboard_contact_path(phone_call.contact)
      )
    end

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
    end
  end

  it "can list all phone calls for a batch operation" do
    user = create(:user)
    phone_call = create_phone_call(
      account: user.account,
      create_batch_operation: create(:phone_call_create_batch_operation, account: user.account)
    )
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_batch_operation_phone_calls_path(phone_call.create_batch_operation))

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :back,
        href: dashboard_batch_operation_path(phone_call.create_batch_operation)
      )
    end

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
    end
  end

  it "can show a phone call" do
    user = create(:user)
    phone_call = create_phone_call(
      account: user.account,
      create_batch_operation: create(:phone_call_create_batch_operation, account: user.account),
      queue_batch_operation: create(:phone_call_queue_batch_operation, account: user.account),
      queue_remote_fetch_batch_operation: create(:phone_call_queue_remote_fetch_batch_operation, account: user.account)
    )

    sign_in(user)
    visit(dashboard_phone_call_path(phone_call))

    within("#resource") do
      expect(page).to have_content(phone_call.id)

      expect(page).to have_link(
        phone_call.callout_participation_id,
        href: dashboard_callout_participation_path(phone_call.callout_participation)
      )

      expect(page).to have_link(
        phone_call.callout_id,
        href: dashboard_callout_path(phone_call.callout_id)
      )

      expect(page).to have_link(
        phone_call.contact_id,
        href: dashboard_contact_path(phone_call.contact_id)
      )

      expect(page).to have_link(
        phone_call.create_batch_operation_id,
        href: dashboard_batch_operation_path(phone_call.create_batch_operation_id)
      )

      expect(page).to have_link(
        phone_call.queue_batch_operation_id,
        href: dashboard_batch_operation_path(phone_call.queue_batch_operation_id)
      )

      expect(page).to have_link(
        phone_call.queue_remote_fetch_batch_operation_id,
        href: dashboard_batch_operation_path(phone_call.queue_remote_fetch_batch_operation_id)
      )

      expect(page).to have_content("#")
      expect(page).to have_content("Phone Number")
      expect(page).to have_content("Contact")
      expect(page).to have_content("Direction")
      expect(page).to have_content("Status")
      expect(page).to have_content("Callout Participation")
      expect(page).to have_content("Callout")
      expect(page).to have_content("Call Flow Logic")
      expect(page).to have_content("Remote Call ID")
      expect(page).to have_content("Remote Status")
      expect(page).to have_content("Remote Error Message")
      expect(page).to have_content("Remotely Queued At")
      expect(page).to have_content("Created At")
      expect(page).to have_content("Remote Request Params")
      expect(page).to have_content("Remote Response")
      expect(page).to have_content("Remote Queue Response")
      expect(page).to have_content("Metadata")
    end
  end

  it "can delete a phone call" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit dashboard_phone_call_path(phone_call)

    click_action_button(:delete, type: :link)

    expect(current_path).to eq(
      dashboard_phone_calls_path
    )
    expect(page).to have_text("Phone Call was successfully destroyed.")
  end

  def create_phone_call(account:, **options)
    callout_participation = options.delete(:callout_participation) || create_callout_participation(
      account: account
    )
    create(:phone_call, { callout_participation: callout_participation }.merge(options))
  end
end
