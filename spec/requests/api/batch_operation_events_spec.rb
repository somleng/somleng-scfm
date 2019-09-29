require "rails_helper"

RSpec.resource "Batch Operation Events" do
  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }

  header("Content-Type", "application/json")

  post "/api/batch_operations/:batch_operation_id/batch_operation_events" do
    parameter(
      :event,
      "Either `queue` or `requeue`.",
      required: true
    )

    example "Create a Batch Operation Event" do
      batch_operation = create_batch_operation(
        account: account,
        status: BatchOperation::Base::STATE_PREVIEW
      )

      set_authorization_header(access_token: access_token)
      perform_enqueued_jobs do
        do_request(
          batch_operation_id: batch_operation.id,
          event: "queue"
        )
      end

      expect(response_status).to eq(201)
      expect(response_headers.fetch("Location")).to eq(api_batch_operation_path(batch_operation))
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("status")).to eq("queued")
      expect(batch_operation.reload).to be_finished
    end

    example "Queue remote phone calls", document: false do
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

      set_authorization_header(access_token: access_token)
      perform_enqueued_jobs do
        do_request(
          batch_operation_id: batch_operation.id,
          event: "queue"
        )
      end

      expect(response_status).to eq(201)
      phone_call.reload
      expect(phone_call).to be_remotely_queued
      expect(phone_call.remotely_queued_at).to be_present
    end

    example "Queue a remote status fetch", document: false do
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

      set_authorization_header(access_token: access_token)
      perform_enqueued_jobs do
        do_request(
          batch_operation_id: batch_operation.id,
          event: "queue"
        )
      end

      expect(response_status).to eq(201)
      phone_call.reload
      expect(phone_call).to be_in_progress
    end

    example "Requeue a batch operation", document: false do
      batch_operation = create_batch_operation(
        account: account,
        status: BatchOperation::Base::STATE_FINISHED
      )

      set_authorization_header(access_token: access_token)
      perform_enqueued_jobs do
        do_request(
          batch_operation_id: batch_operation.id,
          event: "requeue"
        )
      end

      expect(response_status).to eq(201)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("status")).to eq("queued")
      expect(batch_operation.reload).to be_finished
    end

    example "Queue a finished batch operation", document: false do
      batch_operation = create_batch_operation(
        account: account,
        status: BatchOperation::Base::STATE_FINISHED
      )

      set_authorization_header(access_token: access_token)
      do_request(
        batch_operation_id: batch_operation.id,
        event: "queue"
      )

      expect(response_status).to eq(422)
    end
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
