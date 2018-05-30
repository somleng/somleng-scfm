require "rails_helper"

RSpec.describe "Accounts" do
  let(:account) { create(:account, :super_admin) }
  let(:access_token) { create(:access_token, resource_owner: account) }

  it "can list all accounts" do
    filtered_account = create(
      :account,
      metadata: {
        "foo" => "bar"
      }
    )

    get(
      api_accounts_path(
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
    expect(parsed_body.first.fetch("id")).to eq(filtered_account.id)
  end

  it "cannot list any accounts if not super admin" do
    account = create(:account)
    access_token = create(:access_token, resource_owner: account)

    get(
      api_accounts_path,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("401")
  end

  it "can create an account" do
    post(
      api_accounts_path,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
  end

  it "can fetch an account" do
    other_account = create(:account)

    get(
      api_account_path(other_account),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.fetch("id")).to eq(other_account.id)
  end

  it "can update an account" do
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

    patch(
      api_account_path(other_account),
      params: body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(other_account.reload.metadata).to eq(body.fetch(:metadata))
    expect(other_account.twilio_account_sid).to eq(body.fetch(:twilio_account_sid))
    expect(other_account.twilio_auth_token).to eq(body.fetch(:twilio_auth_token))
    expect(other_account.somleng_account_sid).to eq(body.fetch(:somleng_account_sid))
    expect(other_account.somleng_auth_token).to eq(body.fetch(:somleng_auth_token))
    expect(other_account.platform_provider_name).to eq(body.fetch(:platform_provider_name))
    expect(other_account.call_flow_logic).to eq(body.fetch(:call_flow_logic))
    expect(other_account.settings).to eq(body.fetch(:settings))
  end

  it "can delete an account" do
    other_account = create(:account)

    delete(
      api_account_path(other_account),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(Account.find_by_id(other_account.id)).to eq(nil)
  end

  it "cannot delete an account with existing users" do
    other_account = create(:account)
    _user = create(:user, account: other_account)

    delete(
      api_account_path(other_account),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end
end
