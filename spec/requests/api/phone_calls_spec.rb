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
    example "List phone calls for a contact", document: false do
      phone_call = create_phone_call(account: account)
      _other_phone_call = create_phone_call(account: account)

      set_authorization_header(access_token: access_token)
      do_request(contact_id: phone_call.contact.id)

      assert_filtered!(phone_call)
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
