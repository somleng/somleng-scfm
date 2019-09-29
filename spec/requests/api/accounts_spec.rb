require "rails_helper"

RSpec.resource "Accounts" do
  let(:account) { create(:account, :super_admin) }
  let(:access_token) { create_access_token(resource_owner: account) }

  header("Content-Type", "application/json")

  get "/api/accounts" do
    example "List all Accounts" do
      filtered_account = create(
        :account,
        metadata: {
          "foo" => "bar"
        }
      )

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
      expect(parsed_body.first.fetch("id")).to eq(filtered_account.id)
    end

    example "cannot list any accounts if not super admin", document: false do
      account = create(:account)
      access_token = create(:access_token, resource_owner: account)

      set_authorization_header(access_token: access_token)
      do_request

      expect(response_status).to eq(401)
    end
  end

  post "/api/accounts" do
    example "Create an account" do
      set_authorization_header(access_token: access_token)
      do_request

      expect(response_status).to eq(201)
    end
  end

  get "/api/accounts/:id" do
    example "Retrieve an Account" do
      other_account = create(:account)

      set_authorization_header(access_token: access_token)
      do_request(id: other_account.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("id")).to eq(other_account.id)
    end
  end

  patch "/api/accounts/:id" do
    example "can update an account" do
      other_account = create(:account, "metadata" => { "bar" => "baz" })

      body = {
        metadata: { "foo" => "bar" },
        metadata_merge_mode: "replace",
        twilio_account_sid: generate(:twilio_account_sid),
        somleng_account_sid: generate(:somleng_account_sid),
        twilio_auth_token: generate(:auth_token),
        somleng_auth_token: generate(:auth_token),
        call_flow_logic: CallFlowLogic::HelloWorld.to_s,
        platform_provider_name: "somleng",
        settings: {
          "batch_operation_phone_call_create_parameters" => {
            "callout_filter_params" => {
              "status" => "running"
            },
            "callout_participation_filter_params" => {
              "no_phone_calls_or_last_attempt" => "failed"
            },
            "remote_request_params" => {
              "from" => "1234",
              "url" => "https://demo.twilio.com/docs/voice.xml",
              "method" => "GET"
            }
          },
          "batch_operation_phone_call_queue_parameters" => {
            "callout_filter_params" => {
              "status" => "running"
            },
            "phone_call_filter_params" => {
              "status" => "created"
            },
            "limit" => "30"
          },
          "batch_operation_phone_call_queue_remote_fetch_parameters" => {
            "phone_call_filter_params" => {
              "status" => "remotely_queued,in_progress"
            },
            "limit" => "30"
          }
        }
      }

      set_authorization_header(access_token: access_token)
      do_request(id: other_account.id, **body)

      expect(response_status).to eq(204)
      expect(other_account.reload.metadata).to eq(body.fetch(:metadata))
      expect(other_account.twilio_account_sid).to eq(body.fetch(:twilio_account_sid))
      expect(other_account.twilio_auth_token).to eq(body.fetch(:twilio_auth_token))
      expect(other_account.somleng_account_sid).to eq(body.fetch(:somleng_account_sid))
      expect(other_account.somleng_auth_token).to eq(body.fetch(:somleng_auth_token))
      expect(other_account.platform_provider_name).to eq(body.fetch(:platform_provider_name))
      expect(other_account.call_flow_logic).to eq(body.fetch(:call_flow_logic))
      expect(other_account.settings).to eq(body.fetch(:settings))
    end
  end

  delete "/api/accounts/:id" do
    example "can delete an account" do
      other_account = create(:account)

      set_authorization_header(access_token: access_token)
      do_request(id: other_account.id)

      expect(response_status).to eq(204)
      expect(Account.find_by_id(other_account.id)).to eq(nil)
    end

    example "cannot delete an account with existing users", document: false do
      other_account = create(:account)
      _user = create(:user, account: other_account)

      set_authorization_header(access_token: access_token)
      do_request(id: other_account.id)

      expect(response_status).to eq(422)
    end
  end

  def create_access_token(**options)
    create(:access_token, permissions: %i[accounts_read accounts_write], **options)
  end
end
