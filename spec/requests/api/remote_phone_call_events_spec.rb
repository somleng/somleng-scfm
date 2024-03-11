require "rails_helper"

RSpec.resource "Remote Phone Call Events" do
  header("Content-Type", "application/json")

  explanation <<~HEREDOC
    Remote Phone Call Events are created by Somleng or Twilio Webhooks,
    when an event happens in a Phone Call. Setup your Somleng or Twilio Webhook endpoint to point to
    `/api/remote_phone_call_events`
  HEREDOC

  get "/api/remote_phone_call_events" do
    example "List all Remote Phone Call Events" do
      filtered_event = create_remote_phone_call_event(
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )
      create_remote_phone_call_event(account: account)
      create(:remote_phone_call_event)

      set_authorization_header(access_token: access_token)
      do_request(q: { "metadata" => { "foo" => "bar" } })

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(filtered_event.id)
    end
  end

  get "/api/phone_calls/:phone_call_id/remote_phone_call_events" do
    example "List remote phone call events for a phone call", document: false do
      event = create_remote_phone_call_event(account: account)
      _other_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(phone_call_id: event.phone_call.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(event.id)
    end
  end

  get "/api/callout_participations/:callout_participation_id/remote_phone_call_events" do
    example "List remote phone call events for a callout participation", document: false do
      event = create_remote_phone_call_event(account: account)
      _other_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_participation_id: event.phone_call.callout_participation.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(event.id)
    end
  end

  get "/api/callouts/:callout_id/remote_phone_call_events" do
    example "List remote phone call events for a callout", document: false do
      event = create_remote_phone_call_event(account: account)
      _other_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_id: event.callout.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(event.id)
    end
  end

  get "/api/contacts/:contact_id/remote_phone_call_events" do
    example "List remote phone call events for a contact", document: false do
      event = create_remote_phone_call_event(account: account)
      _other_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(contact_id: event.contact.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(event.id)
    end
  end

  get "/api/remote_phone_call_events/:id" do
    example "Retrieve a Remote Phone Call Event" do
      remote_phone_call_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: remote_phone_call_event.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.remote_phone_call_events.find(parsed_response.fetch("id"))
      ).to eq(remote_phone_call_event)
    end
  end

  patch "/api/remote_phone_call_events/:id" do
    example "Update a Remote Phone Call Event" do
      remote_phone_call_event = create_remote_phone_call_event(
        account: account, metadata: { "bar" => "baz" }
      )

      request_body = {
        metadata: {
          "foo" => "bar"
        },
        metadata_merge_mode: "replace"
      }

      set_authorization_header(access_token: access_token)
      do_request(id: remote_phone_call_event.id, **request_body)

      expect(response_status).to eq(204)
      remote_phone_call_event.reload
      expect(remote_phone_call_event.metadata).to eq(request_body.fetch(:metadata))
    end
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[remote_phone_call_events_read remote_phone_call_events_write],
      **options
    )
  end

  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }
end
