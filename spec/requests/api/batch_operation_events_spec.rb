require "rails_helper"

RSpec.describe "Batch Operation Events" do
  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }

  it "can queue a batch operation" do
    batch_operation = create_batch_operation(
      account: account,
      status: BatchOperation::Base::STATE_PREVIEW
    )

    perform_enqueued_jobs do
      post(
        api_batch_operation_batch_operation_events_path(batch_operation),
        params: { event: "queue" },
        headers: build_authorization_headers(access_token: access_token)
      )
    end

    expect(response.code).to eq("201")
    expect(response.headers["Location"]).to eq(api_batch_operation_path(batch_operation))
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.fetch("status")).to eq("queued")
    expect(batch_operation.reload).to be_finished
  end

  it "can queue remote phone calls" do
    twilio_account_sid = generate(:twilio_account_sid)
    account = create(
      :account,
      platform_provider_name: "twilio",
      twilio_account_sid: twilio_account_sid
    )
    access_token = create_access_token(resource_owner: account)

    batch_operation = create_batch_operation(
      factory: :phone_call_queue_batch_operation,
      account: account,
      status: BatchOperation::Base::STATE_PREVIEW
    )

    phone_call = create_phone_call(account: account)

    stub_request(
      :post,
      "https://api.twilio.com/2010-04-01/Accounts/#{twilio_account_sid}/Calls.json"
    ).to_return(
      body: { "sid" => SecureRandom.uuid }.to_json
    )

    perform_enqueued_jobs do
      post(
        api_batch_operation_batch_operation_events_path(batch_operation),
        params: { event: "queue" },
        headers: build_authorization_headers(access_token: access_token)
      )
    end

    expect(response.code).to eq("201")
    phone_call.reload
    expect(phone_call).to be_remotely_queued
    expect(phone_call.remotely_queued_at).to be_present
  end

  it "can queue a remote status fetch" do
    twilio_account_sid = generate(:twilio_account_sid)
    remote_call_id = SecureRandom.uuid
    account = create(
      :account,
      platform_provider_name: "twilio",
      twilio_account_sid: twilio_account_sid
    )
    access_token = create_access_token(resource_owner: account)

    batch_operation = create_batch_operation(
      factory: :phone_call_queue_remote_fetch_batch_operation,
      account: account,
      status: BatchOperation::Base::STATE_PREVIEW
    )

    phone_call = create_phone_call(
      account: account,
      status: PhoneCall::STATE_REMOTELY_QUEUED,
      remotely_queued_at: Time.now,
      remote_call_id: remote_call_id
    )

    stub_request(
      :get,
      "https://api.twilio.com/2010-04-01/Accounts/#{twilio_account_sid}/Calls/#{remote_call_id}.json"
    ).to_return(
      body: { "status" => "in-progress" }.to_json
    )

    perform_enqueued_jobs do
      post(
        api_batch_operation_batch_operation_events_path(batch_operation),
        params: { event: "queue" },
        headers: build_authorization_headers(access_token: access_token)
      )
    end

    expect(response.code).to eq("201")
    phone_call.reload
    expect(phone_call).to be_in_progress
  end

  it "can requeue a batch operation" do
    batch_operation = create_batch_operation(
      account: account,
      status: BatchOperation::Base::STATE_FINISHED
    )

    perform_enqueued_jobs do
      post(
        api_batch_operation_batch_operation_events_path(batch_operation),
        params: { event: "requeue" },
        headers: build_authorization_headers(access_token: access_token)
      )
    end

    expect(response.code).to eq("201")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.fetch("status")).to eq("queued")
    expect(batch_operation.reload).to be_finished
  end

  it "cannot queue a finished batch operation" do
    batch_operation = create_batch_operation(
      account: account,
      status: BatchOperation::Base::STATE_FINISHED
    )

    post(
      api_batch_operation_batch_operation_events_path(batch_operation),
      params: { event: "queue" },
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  def create_access_token(**options)
    create(:access_token, permissions: %i[batch_operations_write], **options)
  end

  def create_batch_operation(account:, factory: :batch_operation, **options)
    create(
      factory,
      account: account,
      status: BatchOperation::Base::STATE_FINISHED,
      **options
    )
  end
end
