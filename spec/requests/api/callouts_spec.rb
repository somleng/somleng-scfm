require "rails_helper"

RSpec.resource "Callouts" do
  header("Content-Type", "application/json")

  get "/api/callouts" do
    example "List all Callouts" do
      filtered_callout = create(
        :callout,
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )
      create(:callout, account: account)
      create(:callout)

      set_authorization_header(access_token: access_token)
      do_request(
        q: {
          "metadata" => { "foo" => "bar" }
        }
      )

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(filtered_callout.id)
    end
  end

  get "/api/contacts/:contact_id/callouts" do
    example "List all Callouts for a contact", document: false do
      contact = create(:contact, account: account)
      callout = create(:callout, account: account)
      _callout_participation = create_callout_participation(
        account: account,
        contact: contact,
        callout: callout
      )
      _other_callout = create(:callout, account: account)

      set_authorization_header(access_token: access_token)
      do_request(contact_id: contact.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(callout.id)
    end
  end

  post "/api/callouts" do
    example "Create a Callout" do
      request_body = {
        call_flow_logic: CallFlowLogic::HelloWorld.to_s,
        audio_url: "https://www.example.com/sample.mp3",
        metadata: {
          "foo" => "bar"
        },
        settings: {
          "rapidpro" => {
            "flow_id" => "flow-id"
          }
        }
      }

      set_authorization_header(access_token: access_token)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      created_callout = account.callouts.find(parsed_response.fetch("id"))
      expect(created_callout.metadata).to eq(request_body.fetch(:metadata))
      expect(created_callout.settings).to eq(request_body.fetch(:settings))
      expect(created_callout.call_flow_logic).to eq(request_body.fetch(:call_flow_logic))
      expect(created_callout.audio_url).to eq(request_body.fetch(:audio_url))
    end
  end

  get "/api/callouts/:id" do
    example "Retrieve a Callout" do
      callout = create(:callout, account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: callout.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.callouts.find(parsed_response.fetch("id"))
      ).to eq(callout)
    end
  end

  patch "/api/callouts/:id" do
    example "Update a Callout" do
      callout = create(
        :callout,
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )

      request_body = { metadata: { "bar" => "foo" }, metadata_merge_mode: "replace" }

      set_authorization_header(access_token: access_token)
      do_request(id: callout.id, **request_body)

      expect(response_status).to eq(204)
      callout.reload
      expect(callout.metadata).to eq(request_body.fetch(:metadata))
    end
  end

  delete "/api/callouts/:id" do
    example "Delete a Callout" do
      callout = create(:callout, account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: callout.id)

      expect(response_status).to eq(204)
      expect(Callout.find_by_id(callout.id)).to eq(nil)
    end

    example "Delete a Callout with callout participations", document: false do
      callout = create(:callout, account: account)
      _callout_participation = create_callout_participation(
        account: account, callout: callout
      )

      set_authorization_header(access_token: access_token)
      do_request(id: callout.id)

      expect(response_status).to eq(422)
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

      assert_batch_operation_created!(account: account, request_body: body)
      expect(callout.reload.callout_populations.count).to eq(1)
    end
  end

  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[
        callouts_read
        callouts_write
        batch_operations_read
        batch_operations_write
      ],
      **options
    )
  end
end
