require "rails_helper"

RSpec.resource "Batch Operations" do
  let(:access_token) { create_access_token }
  let(:account) { access_token.resource_owner }

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

  post "/api/callouts/:callout_id/batch_operations" do
    example "Populate a Callout" do
      callout = create(:callout, account: account)
      body = build_batch_operation_request_body(
        type: "BatchOperation::CalloutPopulation"
      )

      set_authorization_header(access_token: access_token)
      do_request(callout_id: callout.id, **body)

      assert_created!(account: account, request_body: body)
      expect(callout.reload.callout_populations.count).to eq(1)
    end
  end

  post "/api/batch_operations" do
    parameter(
      :type,
      "One of: " + BatchOperation::Base::PERMITTED_API_TYPES.map { |type| "`#{type}``" }.join(", "),
      required: true
    )

    parameter(
      :parameters,
      "List of parameters for the batch operation."
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

      assert_created!(account: account, request_body: body)
    end

    example "Queue Phone Calls", document: false do
      body = build_batch_operation_request_body(
        type: "BatchOperation::PhoneCallQueue"
      )

      set_authorization_header(access_token: access_token)
      do_request(body)

      assert_created!(account: account, request_body: body)
    end

    example "Queue Remote Fetch Status", document: false do
      body = build_batch_operation_request_body(
        type: "BatchOperation::PhoneCallQueueRemoteFetch"
      )

      set_authorization_header(access_token: access_token)
      do_request(body)

      assert_created!(account: account, request_body: body)
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

  get "/api/callouts/:callout_id/batch_operations" do
    example "List all callout batch operations", document: false do
      callout = create(:callout, account: account)
      callout_population = create(:callout_population, callout: callout, account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_id: callout.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.batch_operations.find(parsed_response.first.fetch("id"))
      ).to eq(callout_population)
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

  def assert_created!(account:, request_body:)
    expect(response_status).to eq(201)
    parsed_response = JSON.parse(response_body)
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

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[batch_operations_read batch_operations_write], **options
    )
  end
end
