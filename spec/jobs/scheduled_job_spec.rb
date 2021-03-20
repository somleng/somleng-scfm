require "rails_helper"

RSpec.describe ScheduledJob do
  it "queues phone calls per account" do
    account = create(:account)

    created_phone_call_from_running_callout = create_phone_call(
      account: account,
      status: :created,
      callout_status: :running
    )
    created_phone_call_from_stopped_callout = create_phone_call(
      account: account,
      status: :created,
      callout_status: :stopped
    )
    queued_phone_call = create_phone_call(
      account: account,
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

  it "fetches unknown call statuses" do
    account = create(:account)

    phone_call_with_unknown_status = create_phone_call(
      account: account,
      status: :in_progress,
      remotely_queued_at: 10.minutes.ago
    )
    _in_progress_phone_call = create_phone_call(
      account: account,
      status: :in_progress,
      remotely_queued_at: Time.current
    )

    ScheduledJob.perform_now

    expect(FetchRemoteCallJob).to have_been_enqueued.exactly(:once)
    expect(FetchRemoteCallJob).to have_been_enqueued.with(phone_call_with_unknown_status)
  end

  it "expires old calls with unknown call statuses" do
    account = create(:account)

    old_phone_call_with_unknown_status = create_phone_call(
      account: account,
      status: :in_progress,
      remotely_queued_at: 24.hours.ago
    )
    phone_call_with_unknown_status = create_phone_call(
      account: account,
      status: :in_progress,
      remotely_queued_at: 10.minutes.ago
    )

    ScheduledJob.perform_now

    expect(old_phone_call_with_unknown_status.reload.status).to eq("expired")
    expect(phone_call_with_unknown_status.reload.status).to eq("in_progress")
  end

  def create_phone_call(account:, callout_status: :running, **attributes)
    callout_participation = create_callout_participation(
      account: account, callout: create(:callout, status: callout_status)
    )

    create(:phone_call, account: account, callout_participation: callout_participation, **attributes)
  end
end
