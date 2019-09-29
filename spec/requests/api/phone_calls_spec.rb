require "rails_helper"

RSpec.resource "Phone Calls" do
  header("Content-Type", "application/json")

  get "/api/phone_calls" do
    example "List all Phone Calls" do
      phone_call = create_phone_call(
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )

      create_phone_call(account: account)
      create(:phone_call)

      set_authorization_header(access_token: access_token)
      do_request(
        q: {
          "metadata" => { "foo" => "bar" }
        }
      )

      assert_filtered!(phone_call)
    end
  end

  get "/api/callout_participations/:callout_participation_id/phone_calls" do
    example "List phone calls for a callout participation", document: false do
      phone_call = create_phone_call(account: account)
      _other_phone_call = create_phone_call(account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_participation_id: phone_call.callout_participation.id)

      assert_filtered!(phone_call)
    end
  end

  get "/api/callouts/:callout_id/phone_calls" do
    example "List phone calls for a callout", document: false do
      phone_call = create_phone_call(account: account)
      _other_phone_call = create_phone_call(account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_id: phone_call.callout.id)

      assert_filtered!(phone_call)
    end
  end

  get "/api/contacts/:contact_id/phone_calls" do
    example "List phone calls for a contact" do
      phone_call = create_phone_call(account: account)
      _other_phone_call = create_phone_call(account: account)

      set_authorization_header(access_token: access_token)
      do_request(contact_id: phone_call.contact.id)

      assert_filtered!(phone_call)
    end
  end

  get "/api/batch_operations/:batch_operation_id/phone_calls" do
    example "List phone calls for a create phone calls batch operation", document: false do
      batch_operation = create(:phone_call_create_batch_operation, account: account)
      phone_call = create_phone_call(account: account, create_batch_operation: batch_operation)
      _other_phone_call = create_phone_call(account: account)

      set_authorization_header(access_token: access_token)
      do_request(batch_operation_id: batch_operation.id)

      assert_filtered!(phone_call)
    end

    example "List phone calls for a queue phone calls batch operation", document: false do
      batch_operation = create(:phone_call_queue_batch_operation, account: account)
      phone_call = create_phone_call(account: account, queue_batch_operation: batch_operation)
      _other_phone_call = create_phone_call(account: account)

      set_authorization_header(access_token: access_token)
      do_request(batch_operation_id: batch_operation.id)

      assert_filtered!(phone_call)
    end

    example "List phone calls for a queue remote fetch phone calls batch operation", document: false do
      batch_operation = create(:phone_call_queue_remote_fetch_batch_operation, account: account)
      phone_call = create_phone_call(account: account, queue_remote_fetch_batch_operation: batch_operation)
      _other_phone_call = create_phone_call(account: account)

      set_authorization_header(access_token: access_token)
      do_request(batch_operation_id: batch_operation.id)

      assert_filtered!(phone_call)
    end
  end

  post "/api/callout_participations/:callout_participation_id/phone_calls" do
    parameter(
      :callout_participation_id,
      "The `id` of the callout participation",
      required: true
    )

    parameter(
      :remote_request_params,
      "The request parameters to send to Somleng or Twilio",
      required: true
    )

    example "Create a Phone Call" do
      callout_participation = create_callout_participation(account: account)
      request_body = build_request_body

      set_authorization_header(access_token: access_token)
      do_request(callout_participation_id: callout_participation.id, **request_body)

      expect(response_status).to eq(201)
      created_phone_call = account.phone_calls.last!
      expect(response_headers.fetch("Location")).to eq(api_phone_call_path(created_phone_call))
      expect(created_phone_call.metadata).to eq(request_body.fetch(:metadata))
      expect(created_phone_call.remote_request_params).to eq(request_body.fetch(:remote_request_params))
      expect(created_phone_call.call_flow_logic).to eq(request_body.fetch(:call_flow_logic).to_s)
      expect(created_phone_call.msisdn).to include(request_body.fetch(:msisdn))
    end

    example "Create a Phone Call with invalid request data", document: false do
      callout_participation = create_callout_participation(account: account)
      request_body = build_request_body(remote_request_params: { "foo" => "bar" })

      set_authorization_header(access_token: access_token)
      do_request(callout_participation_id: callout_participation.id, **request_body)

      expect(response_status).to eq(422)
    end
  end

  get "/api/phone_calls/:id" do
    example "Retrieve a Phone Call" do
      phone_call = create_phone_call(account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: phone_call.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.phone_calls.find(parsed_response.fetch("id"))
      ).to eq(phone_call)
    end
  end

  patch "/api/phone_calls/:id" do
    example "Update a Phone Call" do
      phone_call = create_phone_call(
        account: account,
        metadata: { "foo" => "bar" }
      )

      request_body = build_request_body(
        metadata: { "bar" => "foo" },
        metadata_merge_mode: "replace"
      )

      set_authorization_header(access_token: access_token)
      do_request(id: phone_call.id, **request_body)

      expect(response_status).to eq(204)
      phone_call.reload
      expect(phone_call.metadata).to eq(request_body.fetch(:metadata))
      expect(phone_call.remote_request_params).to eq(request_body.fetch(:remote_request_params))
      expect(phone_call.call_flow_logic).to eq(request_body.fetch(:call_flow_logic).to_s)
      expect(phone_call.msisdn).to include(request_body.fetch(:msisdn))
    end
  end

  delete "/api/phone_calls/:id" do
    example "Delete a Phone Call" do
      phone_call = create_phone_call(account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: phone_call.id)

      expect(response_status).to eq(204)
      expect(PhoneCall.find_by_id(phone_call.id)).to eq(nil)
    end

    example "Delete a Phone Call that has been queued", document: false do
      phone_call = create_phone_call(account: account, status: PhoneCall::STATE_QUEUED)

      set_authorization_header(access_token: access_token)
      do_request(id: phone_call.id)

      expect(response_status).to eq(422)
    end
  end

  post "/api/phone_calls/:phone_call_id/phone_call_events" do
    example "Queue a Phone Call" do
      twilio_account_sid = generate(:twilio_account_sid)
      account = create(
        :account,
        platform_provider_name: "twilio",
        twilio_account_sid: twilio_account_sid
      )
      access_token = create_access_token(resource_owner: account)
      phone_call = create_phone_call(account: account)
      remote_call_id = SecureRandom.uuid
      stub_request(
        :post,
        "https://api.twilio.com/2010-04-01/Accounts/#{twilio_account_sid}/Calls.json"
      ).to_return(
        body: { "sid" => remote_call_id }.to_json
      )

      set_authorization_header(access_token: access_token)
      perform_enqueued_jobs do
        do_request(
          phone_call_id: phone_call.id, event: "queue"
        )
      end

      expect(response_status).to eq(201)
      expect(response_headers.fetch("Location")).to eq(api_phone_call_path(phone_call))
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("status")).to eq(PhoneCall::STATE_QUEUED.to_s)
      phone_call.reload
      expect(phone_call).to be_remotely_queued
      expect(phone_call.remote_call_id).to eq(remote_call_id)
      expect(phone_call.remotely_queued_at).to be_present
    end

    example "Queue a remote status fetch", document: false do
      twilio_account_sid = generate(:twilio_account_sid)
      account = create(
        :account,
        platform_provider_name: "twilio",
        twilio_account_sid: twilio_account_sid
      )
      access_token = create_access_token(resource_owner: account)
      remote_call_id = SecureRandom.uuid
      phone_call = create_phone_call(
        :remotely_queued,
        account: account,
        remote_call_id: remote_call_id
      )

      stub_request(
        :get,
        "https://api.twilio.com/2010-04-01/Accounts/#{twilio_account_sid}/Calls/#{remote_call_id}.json"
      ).to_return(
        body: { "status" => "completed" }.to_json
      )

      set_authorization_header(access_token: access_token)

      perform_enqueued_jobs do
        do_request(phone_call_id: phone_call.id, event: "queue_remote_fetch")
      end

      expect(response_status).to eq(201)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("status")).to eq("remotely_queued")
      phone_call.reload
      expect(phone_call).to be_completed
    end

    example "Queue a call that is already queued", document: false do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      phone_call = create_phone_call(
        account: account,
        status: PhoneCall::STATE_QUEUED
      )

      set_authorization_header(access_token: access_token)
      do_request(phone_call_id: phone_call.id, event: "queue")

      expect(response_status).to eq(422)
    end
  end

  def build_request_body(options = {})
    {
      msisdn: options.delete(:msisdn) || generate(:somali_msisdn),
      remote_request_params: options.delete(:remote_request_params) || generate(:twilio_request_params),
      call_flow_logic: options.delete(:call_flow_logic) || CallFlowLogic::HelloWorld,
      metadata: options.delete(:metadata) || { "foo" => "bar" }
    }.merge(options)
  end

  def assert_filtered!(phone_call)
    expect(response_status).to eq(200)
    parsed_body = JSON.parse(response_body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(phone_call.id)
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[phone_calls_read phone_calls_write],
      **options
    )
  end

  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }
end
