require "rails_helper"

RSpec.describe "Batch Operations" do
  let(:access_token) { create(:access_token) }
  let(:account) { access_token.resource_owner }

  it "can list all batch operations" do
    filtered_batch_operation = create(
      :batch_operation,
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )
    create(:batch_operation, account: account)
    create(:batch_operation)

    get(
      api_batch_operations_path(
        q: {
          "metadata" => {
            "foo" => "bar"
          }
        }
      ),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(filtered_batch_operation.id)
  end

  it "can create a BatchOperation::CalloutPopulation" do
    callout = create(:callout, account: account)
    body = build_batch_operation_request_body(
      type: "BatchOperation::CalloutPopulation"
    )

    post(
      api_callout_batch_operations_path(callout),
      params: body,
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_created!(account: account, request_body: body, response: response)
    expect(callout.reload.callout_populations.count).to eq(1)
  end

  it "can create a BatchOperation::PhoneCallCreate" do
    body = build_batch_operation_request_body(
      type: "BatchOperation::PhoneCallCreate",
      parameters: {
        "remote_request_params" => generate(:twilio_request_params)
      }
    )

    post(
      api_batch_operations_path,
      params: body,
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_created!(account: account, request_body: body, response: response)
  end

  it "can create a BatchOperation::PhoneCallQueue" do
    body = build_batch_operation_request_body(
      type: "BatchOperation::PhoneCallQueue"
    )

    post(
      api_batch_operations_path,
      params: body,
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_created!(account: account, request_body: body, response: response)
  end

  it "can create a BatchOperation::PhoneCallQueueRemoteFetch" do
    body = build_batch_operation_request_body(
      type: "BatchOperation::PhoneCallQueueRemoteFetch"
    )

    post(
      api_batch_operations_path,
      params: body,
      headers: build_authorization_headers(access_token: access_token)
    )

    assert_created!(account: account, request_body: body, response: response)
  end

  it "does not create a batch operation with an invalid type" do
    body = build_batch_operation_request_body(
      type: "Contact"
    )

    post(
      api_batch_operations_path,
      params: body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  it "can fetch the batch operations for a callout" do
    callout = create(:callout, account: account)
    callout_population = create(:callout_population, callout: callout, account: account)

    get(
      api_callout_batch_operations_path(callout),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_response = JSON.parse(response.body)
    expect(
      account.batch_operations.find(parsed_response.first.fetch("id"))
    ).to eq(callout_population)
  end

  it "can fetch a batch operation" do
    batch_operation = create(:batch_operation, account: account)

    get(
      api_batch_operation_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    expect(response.body).to eq(batch_operation.to_json)
  end

  it "can update a batch operation" do
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

    patch(
      api_batch_operation_path(batch_operation),
      params: body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    batch_operation.reload
    expect(batch_operation.metadata).to eq(body.fetch(:metadata))
    expect(batch_operation.parameters).to eq(body.fetch(:parameters))
  end

  it "can delete a batch operation" do
    batch_operation = create(:batch_operation, account: account)

    delete(
      api_batch_operation_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(BatchOperation::Base.find_by_id(batch_operation.id)).to eq(nil)
  end

  it "cannot delete a callout population with callout participations" do
    callout_population = create(:callout_population, account: account)
    create(:callout_participation, callout_population: callout_population)

    delete(
      api_batch_operation_path(callout_population),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  def assert_created!(account:, request_body:, response:)
    expect(response.code).to eq("201")
    parsed_response = JSON.parse(response.body)
    expect(parsed_response.fetch("metadata")).to eq(request_body.fetch(:metadata))
    expect(parsed_response.fetch("parameters")).to eq(request_body.fetch(:parameters))
    expect(
      account.batch_operations.find(parsed_response.fetch("id")).class
    ).to eq(request_body.fetch(:type).constantize)
  end

  def build_batch_operation_request_body(parameters: {}, metadata: {}, **options)
    {
      metadata: {
        "foo" => "bar"
      }.merge(metadata),
      parameters: {
        "skip_validate_preview_presence" => "1"
      }.merge(parameters)
    }.merge(options)
  end
end
