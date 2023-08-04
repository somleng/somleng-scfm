require "rails_helper"

RSpec.describe ScheduledJob do
  it "queues phone calls per account" do
    account = create(:account)

    created_phone_call_from_running_callout = create_phone_call(
      account:,
      status: :created,
      callout_status: :running
    )
    created_phone_call_from_stopped_callout = create_phone_call(
      account:,
      status: :created,
      callout_status: :stopped
    )
    queued_phone_call = create_phone_call(
      account:,
      status: :queued,
      callout_status: :running
    )

    ScheduledJob.perform_now

    expect(created_phone_call_from_running_callout.reload.status).to eq("queued")
    expect(created_phone_call_from_stopped_callout.reload.status).to eq("created")
    expect(queued_phone_call.reload.status).to eq("queued")

    expect(QueueRemoteCallJob).to have_been_enqueued.exactly(:once)
    expect(QueueRemoteCallJob).to have_been_enqueued.with(created_phone_call_from_running_callout)
  end

  it "fetches in progress call statuses" do
    account = create(:account)

    phone_call_with_in_progress_status = create_phone_call(
      account:,
      status: :in_progress,
      remotely_queued_at: 10.minutes.ago
    )
    _in_progress_phone_call = create_phone_call(
      account:,
      status: :in_progress,
      remotely_queued_at: Time.current
    )
    _in_progress_phone_call = create_phone_call(
      account:,
      status: :in_progress,
      remotely_queued_at: 10.minutes.ago,
      remote_status_fetch_queued_at: Time.current
    )

    ScheduledJob.perform_now

    expect(FetchRemoteCallJob).to have_been_enqueued.exactly(:once)
    expect(FetchRemoteCallJob).to have_been_enqueued.with(phone_call_with_in_progress_status)
    expect(phone_call_with_in_progress_status.reload.remote_status_fetch_queued_at).to be_present
  end

  def create_phone_call(account:, callout_status: :running, **attributes)
    callout = create(:callout, account:, status: callout_status)
    callout_participation = create_callout_participation(
      account:, callout:
    )

    create(:phone_call, account:, callout:,
                        callout_participation:, **attributes)
  end
end
