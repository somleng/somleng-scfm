require "rails_helper"

RSpec.describe "Callout Participations" do
  it "can list all callout participations" do
    callout_participation = create_callout_participation(
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )
    create_callout_participation(account: account)
    create(:callout_participation)

    get(
      api_callout_participations_path(q: { "metadata" => { "foo" => "bar" } }),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(callout_participation)
  end

  it "can list all callout participations for a callout" do
    callout_participation = create_callout_participation(account: account)
    _other_callout_participation = create_callout_participation(account: account)

    get(
      api_callout_callout_participations_path(callout_participation.callout),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(callout_participation)
  end

  it "can list all callout participations for a contact" do
    callout_participation = create_callout_participation(account: account)
    _other_callout_participation = create_callout_participation(account: account)

    get(
      api_contact_callout_participations_path(callout_participation.contact),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(callout_participation)
  end

  it "can list all callout participations for a callout population" do
    batch_operation = create(:callout_population, account: account)
    callout_participation = create_callout_participation(
      account: account,
      callout_population: batch_operation
    )
    _other_callout_participation = create_callout_participation(account: account)

    get(
      api_batch_operation_callout_participations_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(callout_participation)
  end

  it "can list all callout participations for a phone call create batch operation" do
    batch_operation = create(:phone_call_create_batch_operation, account: account)
    phone_call = create_phone_call(
      account: account,
      create_batch_operation: batch_operation
    )
    _other_phone_call = create_phone_call(account: account)

    get(
      api_batch_operation_callout_participations_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(phone_call.callout_participation)
  end

  it "can preview callout participations for a phone call create batch operation" do
    callout_participation = create_callout_participation(
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )
    _other_callout_participation = create_callout_participation(
      account: account
    )

    batch_operation = create(
      :phone_call_create_batch_operation,
      account: account,
      callout_participation_filter_params: { metadata: callout_participation.metadata }
    )

    get(
      api_batch_operation_preview_callout_participations_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_filtered!(callout_participation)
  end

  it "can create a callout participation" do
    callout = create(:callout, account: account)
    contact = create(:contact, account: account)

    request_body = build_request_body(contact_id: contact.id)

    post(
      api_callout_callout_participations_path(callout),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    created_callout_participation = account.callout_participations.last
    expect(
      response.headers.fetch("Location")
    ).to eq(api_callout_participation_path(created_callout_participation))
    expect(created_callout_participation.msisdn).to include(request_body.fetch(:msisdn))
    expect(created_callout_participation.callout).to eq(callout)
    expect(created_callout_participation.contact).to eq(contact)
    expect(created_callout_participation.metadata).to eq(request_body.fetch(:metadata))
    expect(created_callout_participation.call_flow_logic).to eq(request_body.fetch(:call_flow_logic).to_s)
  end

  it "does not create a callout participation without valid data" do
    callout = create(:callout, account: account)
    post(
      api_callout_callout_participations_path(callout),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  it "can fetch a callout participation" do
    callout_participation = create_callout_participation(account: account)

    get(
      api_callout_participation_path(callout_participation),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_response = JSON.parse(response.body)
    expect(
      account.callout_participations.find(parsed_response.fetch("id"))
    ).to eq(callout_participation)
  end

  it "can update a callout participation" do
    callout_participation = create_callout_participation(
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )

    contact = create(:contact, account: account)
    request_body = build_request_body(
      contact_id: contact.id,
      metadata: {
        "bar" => "foo"
      },
      metadata_merge_mode: "replace"
    )

    patch(
      api_callout_participation_path(callout_participation),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    callout_participation.reload
    expect(callout_participation.contact).not_to eq(contact)
    expect(callout_participation.msisdn).to include(request_body.fetch(:msisdn))
    expect(callout_participation.metadata).to eq(request_body.fetch(:metadata))
    expect(callout_participation.call_flow_logic).to eq(request_body.fetch(:call_flow_logic).to_s)
  end

  it "can delete a callout participation" do
    callout_participation = create_callout_participation(account: account)

    delete(
      api_callout_participation_path(callout_participation),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(CalloutParticipation.find_by_id(callout_participation.id)).to eq(nil)
  end

  it "cannot delete a callout participation with phone calls" do
    callout_participation = create_callout_participation(account: account)
    _phone_call = create_phone_call(account: account, callout_participation: callout_participation)

    delete(
      api_callout_participation_path(callout_participation),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  def build_request_body(options = {})
    {
      contact_id: options.delete(:contact),
      msisdn: options.delete(:msisdn) || generate(:somali_msisdn),
      call_flow_logic: options.delete(:call_flow_logic) || CallFlowLogic::HelloWorld,
      metadata: options.delete(:metadata) || { "foo" => "bar" }
    }.merge(options)
  end

  def assert_filtered!(callout_participation)
    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(callout_participation.id)
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[callout_participations_read callout_participations_write],
      **options
    )
  end

  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }
end
