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
        href: dashboard_phone_calls_path(q: {status: "created"})
      )
    end

    expect(page).to have_title("Phone Calls")

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
      expect(page).to have_content("#")
      expect(page).to have_link(
        phone_call.id,
        href: dashboard_phone_call_path(phone_call)
      )

      expect(page).to have_sortable_column("msisdn")
      expect(page).to have_sortable_column("status")
      expect(page).to have_sortable_column("duration")
      expect(page).to have_sortable_column("created_at")
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
      account: user.account, callout_participation: callout_participation
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

  it "can list all phone calls for a batch operation" do
    user = create(:user)
    phone_call = create_phone_call(
      account: user.account,
      create_batch_operation: create(:phone_call_create_batch_operation, account: user.account)
    )
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_batch_operation_phone_calls_path(phone_call.create_batch_operation))

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

    within("#related_links") do
      expect(page).to have_link_to_action(
        :index,
        key: :remote_phone_call_events,
        href: dashboard_phone_call_remote_phone_call_events_path(phone_call)
      )
    end

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
      expect(page).to have_content("Phone number")
      expect(page).to have_content("Contact")
      expect(page).to have_content("Direction")
      expect(page).to have_content("Status")
      expect(page).to have_content("Duration")
      expect(page).to have_content("Callout participation")
      expect(page).to have_content("Callout")
      expect(page).to have_content("Call flow")
      expect(page).to have_content("Remote call sid")
      expect(page).to have_content("Remote status")
      expect(page).to have_content("Remote error message")
      expect(page).to have_content("Remotely queued at")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Remote request params")
      expect(page).to have_content("Remote response")
      expect(page).to have_content("Remote queue response")
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
    expect(page).to have_text("was successfully destroyed")
  end

  it "cannot delete a phone call with events" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)
    create(:remote_phone_call_event, phone_call: phone_call)

    sign_in(user)
    visit dashboard_phone_call_path(phone_call)
    click_action_button(:delete, type: :link)

    expect(current_path).to eq(
      dashboard_phone_call_path(phone_call)
    )
    expect(page).to have_text("could not be destroyed")
  end

  it "can queue a phone call" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit dashboard_phone_call_path(phone_call)
    clear_enqueued_jobs
    within("#page_actions") do
      expect {
        click_action_button(:queue, key: :phone_calls, type: :link)
      }.to enqueue_job(QueueRemoteCallJob).with(phone_call.id)
    end

    expect(phone_call.reload).to be_queued
    expect(page).to have_text("Event was successfully created.")
    expect(page).not_to have_link_to_action(:queue, key: :phone_calls)
  end

  it "can fetch the remote status of a phone call" do
    user = create(:user)
    phone_call = create_phone_call(
      :remotely_queued,
      account: user.account
    )

    sign_in(user)
    visit dashboard_phone_call_path(phone_call)
    clear_enqueued_jobs
    within("#page_actions") do
      expect {
        click_action_button(:queue_remote_fetch, key: :phone_calls, type: :link)
      }.to enqueue_job(FetchRemoteCallJob).with(phone_call.id)
    end

    expect(phone_call.reload).to be_remotely_queued
    expect(page).to have_text("Event was successfully created.")
  end
end
