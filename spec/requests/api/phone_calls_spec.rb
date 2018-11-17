require "rails_helper"

RSpec.describe "Phone Calls" do
  it "can list all phone calls" do
    phone_call = create_phone_call(
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )

    create_phone_call(account: account)
    create(:phone_call)

    get(
      api_phone_calls_path(q: { "metadata" => { "foo" => "bar" } }),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call)
    response.body
  end

  it "can list all phone calls for a callout participation" do
    phone_call = create_phone_call(account: account)
    _other_phone_call = create_phone_call(account: account)

    get(
      api_callout_participation_phone_calls_path(phone_call.callout_participation),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call)
  end

  it "can list all phone calls for a callout" do
    phone_call = create_phone_call(account: account)
    _other_phone_call = create_phone_call(account: account)

    get(
      api_callout_phone_calls_path(phone_call.callout),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call)
  end

  it "can list all phone calls for a contact" do
    phone_call = create_phone_call(account: account)
    _other_phone_call = create_phone_call(account: account)

    get(
      api_contact_phone_calls_path(phone_call.contact),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call)
  end

  it "can list all phone calls for a create phone calls batch operation" do
    batch_operation = create(:phone_call_create_batch_operation, account: account)
    phone_call = create_phone_call(account: account, create_batch_operation: batch_operation)
    _other_phone_call = create_phone_call(account: account)

    get(
      api_batch_operation_phone_calls_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call)
  end

  it "can list all phone calls for a queue phone calls batch operation" do
    batch_operation = create(:phone_call_queue_batch_operation, account: account)
    phone_call = create_phone_call(account: account, queue_batch_operation: batch_operation)
    _other_phone_call = create_phone_call(account: account)

    get(
      api_batch_operation_phone_calls_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call)
  end

  it "can list all phone calls for a queue remote fetch phone calls batch operation" do
    batch_operation = create(:phone_call_queue_remote_fetch_batch_operation, account: account)
    phone_call = create_phone_call(account: account, queue_remote_fetch_batch_operation: batch_operation)
    _other_phone_call = create_phone_call(account: account)

    get(
      api_batch_operation_phone_calls_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call)
  end

  it "can preview phone calls for a phone call queue batch operation" do
    phone_call = create_phone_call(
      account: account,
      metadata: { "foo" => "bar" }
    )
    _other_phone_call = create_phone_call(account: account)

    batch_operation = create(
      :phone_call_queue_batch_operation,
      account: account,
      phone_call_filter_params: { metadata: phone_call.metadata }
    )

    get(
      api_batch_operation_preview_phone_calls_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call)
  end

  it "can preview phone calls for a phone call queue remote fetch batch operation" do
    phone_call = create_phone_call(
      account: account,
      metadata: { "foo" => "bar" }
    )
    _other_phone_call = create_phone_call(account: account)

    batch_operation = create(
      :phone_call_queue_remote_fetch_batch_operation,
      account: account,
      phone_call_filter_params: { metadata: phone_call.metadata }
    )

    get(
      api_batch_operation_preview_phone_calls_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call)
  end

  it "can create a phone call" do
    callout_participation = create_callout_participation(account: account)
    request_body = build_request_body

    post(
      api_callout_participation_phone_calls_path(callout_participation),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    created_phone_call = account.phone_calls.last!
    expect(response.headers.fetch("Location")).to eq(api_phone_call_path(created_phone_call))
    expect(created_phone_call.metadata).to eq(request_body.fetch(:metadata))
    expect(created_phone_call.remote_request_params).to eq(request_body.fetch(:remote_request_params))
    expect(created_phone_call.call_flow_logic).to eq(request_body.fetch(:call_flow_logic).to_s)
    expect(created_phone_call.msisdn).to include(request_body.fetch(:msisdn))
  end

  it "cannot create a phone call with invalid request data" do
    callout_participation = create_callout_participation(account: account)
    request_body = build_request_body(remote_request_params: { "foo" => "bar" })

    post(
      api_callout_participation_phone_calls_path(callout_participation),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  it "can fetch a phone call" do
    phone_call = create_phone_call(account: account)

    get(
      api_phone_call_path(phone_call),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_response = JSON.parse(response.body)
    expect(
      account.phone_calls.find(parsed_response.fetch("id"))
    ).to eq(phone_call)
  end

  it "can update a phone call" do
    phone_call = create_phone_call(
      account: account,
      metadata: { "foo" => "bar" }
    )

    request_body = build_request_body(
      metadata: { "bar" => "foo" },
      metadata_merge_mode: "replace"
    )

    patch(
      api_phone_call_path(phone_call),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    phone_call.reload
    expect(phone_call.metadata).to eq(request_body.fetch(:metadata))
    expect(phone_call.remote_request_params).to eq(request_body.fetch(:remote_request_params))
    expect(phone_call.call_flow_logic).to eq(request_body.fetch(:call_flow_logic).to_s)
    expect(phone_call.msisdn).to include(request_body.fetch(:msisdn))
  end

  it "can delete a phone call" do
    phone_call = create_phone_call(account: account)

    delete(
      api_phone_call_path(phone_call),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(PhoneCall.find_by_id(phone_call.id)).to eq(nil)
  end

  it "cannot delete a phone call that has been queued" do
    phone_call = create_phone_call(account: account, status: PhoneCall::STATE_QUEUED)

    delete(
      api_phone_call_path(phone_call),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
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
    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
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
