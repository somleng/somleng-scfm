require "rails_helper"

RSpec.resource "Callout Participations" do
  header("Content-Type", "application/json")

  get "/api/callout_participations" do
    example "List all Callout Participations" do
      no_phone_calls_callout_participation = create_callout_participation(
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )
      having_phone_calls_callout_participation = create_callout_participation(account: account, metadata: { "foo" => "bar" })
      create(:phone_call, callout_participation: having_phone_calls_callout_participation)
      create(:callout_participation)

      set_authorization_header(access_token: access_token)
      do_request(
        q: {
          "metadata" => { "foo" => "bar" },
          having_max_phone_calls_count: 1
        }
      )

      assert_filtered!(no_phone_calls_callout_participation)
    end
  end

  get "/api/callouts/:callout_id/callout_participations" do
    example "List all Callout Participations for a callout", document: false do
      callout_participation = create_callout_participation(account: account)
      _other_callout_participation = create_callout_participation(account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_id: callout_participation.callout.id)

      assert_filtered!(callout_participation)
    end
  end

  get "/api/contacts/:contact_id/callout_participations" do
    example "List all Callout Participations for a contact", document: false do
      callout_participation = create_callout_participation(account: account)
      _other_callout_participation = create_callout_participation(account: account)

      set_authorization_header(access_token: access_token)
      do_request(contact_id: callout_participation.contact.id)

      assert_filtered!(callout_participation)
    end
  end

  post "/api/callouts/:callout_id/callout_participations" do
    example "Create a Callout Participation" do
      callout = create(:callout, account: account)
      contact = create(:contact, account: account)
      request_body = build_request_body(contact_id: contact.id)

      set_authorization_header(access_token: access_token)
      do_request(callout_id: callout.id, **request_body)

      expect(response_status).to eq(201)
      created_callout_participation = account.callout_participations.last
      expect(
        response_headers.fetch("Location")
      ).to eq(api_callout_participation_path(created_callout_participation))
      expect(created_callout_participation.msisdn).to include(request_body.fetch(:msisdn))
      expect(created_callout_participation.callout).to eq(callout)
      expect(created_callout_participation.contact).to eq(contact)
      expect(created_callout_participation.metadata).to eq(request_body.fetch(:metadata))
      expect(created_callout_participation.call_flow_logic).to eq(request_body.fetch(:call_flow_logic).to_s)
    end

    example "Create a Callout Participation with invalid data" do
      callout = create(:callout, account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_id: callout.id)

      expect(response_status).to eq(422)
    end
  end

  get "/api/callout_participations/:id" do
    example "Retrieve a Callout Participation" do
      callout_participation = create_callout_participation(account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: callout_participation.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.callout_participations.find(parsed_response.fetch("id"))
      ).to eq(callout_participation)
    end
  end

  patch "/api/callout_participations/:id" do
    example "Update a Callout Participation" do
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

      set_authorization_header(access_token: access_token)
      do_request(id: callout_participation.id, **request_body)

      expect(response_status).to eq(204)
      callout_participation.reload
      expect(callout_participation.contact).not_to eq(contact)
      expect(callout_participation.msisdn).to include(request_body.fetch(:msisdn))
      expect(callout_participation.metadata).to eq(request_body.fetch(:metadata))
      expect(callout_participation.call_flow_logic).to eq(request_body.fetch(:call_flow_logic).to_s)
    end
  end

  delete "/api/callout_participations/:id" do
    example "Delete a Callout Participation" do
      callout_participation = create_callout_participation(account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: callout_participation.id)

      expect(response_status).to eq(204)
      expect(CalloutParticipation.find_by_id(callout_participation.id)).to eq(nil)
    end

    example "Delete a Callout Participation with phone calls" do
      callout_participation = create_callout_participation(account: account)
      _phone_call = create_phone_call(account: account, callout_participation: callout_participation)

      set_authorization_header(access_token: access_token)
      do_request(id: callout_participation.id)

      expect(response_status).to eq(422)
    end
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
    expect(response_status).to eq(200)
    parsed_body = JSON.parse(response_body)
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
