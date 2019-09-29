require "rails_helper"

RSpec.resource "Batch Operations" do
  header("Content-Type", "application/json")

  get "/api/batch_operations" do
    example "List all Batch Operations" do
      filtered_batch_operation = create(
        :batch_operation,
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )
      create(:batch_operation, account: account)
      create(:batch_operation)

      set_authorization_header(access_token: access_token)
      do_request(
        q: {
          "metadata" => {
            "foo" => "bar"
          }
        }
      )

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(filtered_batch_operation.id)
    end
  end

  post "/api/batch_operations" do
    parameter(
      :type,
      "One of: " + BatchOperation::Base::PERMITTED_API_TYPES.map { |type| "`#{type}`" }.join(", "),
      required: true
    )

    parameter(
      :parameters,
      "Set of key-value pairs which will be used as parameters for the batch operation."
    )

    parameter(
      :metadata,
      "Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format."
    )

    example "Create a Batch Operation" do
      body = build_batch_operation_request_body(
        type: "BatchOperation::PhoneCallCreate",
        parameters: {
          "remote_request_params" => generate(:twilio_request_params)
        }
      )

      set_authorization_header(access_token: access_token)
      do_request(body)

      assert_batch_operation_created!(account: account, request_body: body)
    end

    example "Queue Phone Calls", document: false do
      body = build_batch_operation_request_body(
        type: "BatchOperation::PhoneCallQueue"
      )

      set_authorization_header(access_token: access_token)
      do_request(body)

      assert_batch_operation_created!(account: account, request_body: body)
    end

    example "Queue Remote Fetch Status", document: false do
      body = build_batch_operation_request_body(
        type: "BatchOperation::PhoneCallQueueRemoteFetch"
      )

      set_authorization_header(access_token: access_token)
      do_request(body)

      assert_batch_operation_created!(account: account, request_body: body)
    end

    example "Create a Batch Operation with an invalid type", document: false do
      body = build_batch_operation_request_body(
        type: "Contact"
      )

      set_authorization_header(access_token: access_token)
      do_request(body)

      expect(response_status).to eq(422)
    end
  end

  get "/api/batch_operations/:id" do
    example "Retrieve a Batch Operation" do
      batch_operation = create(:batch_operation, account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: batch_operation.id)

      expect(response_status).to eq(200)
      expect(response_body).to eq(batch_operation.to_json)
    end
  end

  patch "/api/batch_operations/:id" do
    example "Update a Batch Operation" do
      batch_operation = create(
        :batch_operation,
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )
      body = build_batch_operation_request_body(
        metadata: {
          "bar" => "foo"
        },
        metadata_merge_mode: "replace",
        parameters: {
          "foo" => "bar"
        }
      )

      set_authorization_header(access_token: access_token)
      do_request(id: batch_operation.id, **body)

      expect(response_status).to eq(204)
      batch_operation.reload
      expect(batch_operation.metadata).to eq(body.fetch(:metadata))
      expect(batch_operation.parameters).to eq(body.fetch(:parameters))
    end
  end

  delete "/api/batch_operations/:id" do
    example "Delete a Batch Operation" do
      batch_operation = create(:batch_operation, account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: batch_operation.id)

      expect(response_status).to eq(204)
      expect(BatchOperation::Base.find_by_id(batch_operation.id)).to eq(nil)
    end

    example "Delete a callout population with callout participations", document: false do
      callout_population = create(:callout_population, account: account)
      create(:callout_participation, callout_population: callout_population)

      set_authorization_header(access_token: access_token)
      do_request(id: callout_population.id)

      expect(response_status).to eq(422)
    end
  end

  post "/api/batch_operations/:batch_operation_id/batch_operation_events" do
    parameter(
      :event,
      "Either `queue` or `requeue`.",
      required: true
    )

    example "Create a Batch Operation Event" do
      batch_operation = create(
        :batch_operation,
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
      batch_operation = create(
        :phone_call_queue_batch_operation,
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
      batch_operation = create(
        :phone_call_queue_remote_fetch_batch_operation,
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
      batch_operation = create(
        :batch_operation,
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
      batch_operation = create(
        :batch_operation,
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

  let(:access_token) { create_access_token }
  let(:account) { access_token.resource_owner }

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[batch_operations_read batch_operations_write], **options
    )
  end
end
