require "rails_helper"

RSpec.describe "Account Settings" do
  it "can update the account settings", :js do
    user = create(:admin)
    sign_in(user)

    visit(edit_dashboard_account_path)

    expect(page).to have_title("Account Settings")

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.accounts.edit"),
        href: edit_dashboard_account_path
      )
    end

    twilio_account_sid = generate(:twilio_account_sid)
    twilio_auth_token = generate(:auth_token)
    somleng_account_sid = generate(:somleng_account_sid)
    somleng_auth_token = generate(:auth_token)

    choose("Somleng")
    choose("Hello World")
    fill_in("Twilio account sid", with: twilio_account_sid)
    fill_in("Twilio auth token", with: twilio_auth_token)
    fill_in("Somleng account sid", with: somleng_account_sid)
    fill_in("Somleng auth token", with: somleng_auth_token)
    fill_in_key_values_for(
      :settings,
      with: {
        "batch_operation_phone_call_create_parameters:callout_filter_params:status" => "running",
        "batch_operation_phone_call_create_parameters:callout_participation_filter_params:no_phone_calls_or_last_attempt" => "failed",
        "batch_operation_phone_call_create_parameters:remote_request_params:from" => "1234",
        "batch_operation_phone_call_create_parameters:remote_request_params:url" => "https://demo.twilio.com/docs/voice.xml",
        "batch_operation_phone_call_create_parameters:remote_request_params:method" => "GET",
        "batch_operation_phone_call_queue_parameters:callout_filter_params:status" => "running",
        "batch_operation_phone_call_queue_parameters:phone_call_filter_params:status" => "created",
        "batch_operation_phone_call_queue_parameters:limit" => "30",
        "batch_operation_phone_call_queue_remote_fetch_parameters:phone_call_filter_params:status" => "remotely_queued,in_progress",
        "batch_operation_phone_call_queue_remote_fetch_parameters:limit" => "30"
      }
    )

    click_action_button(:update, key: :submit, namespace: :helpers)

    expect(current_path).to eq(edit_dashboard_account_path)
    expect(page).to have_text("Account was successfully updated.")
    user.account.reload
    expect(user.account.platform_provider_name).to eq("somleng")
    expect(user.account.call_flow_logic).to eq("CallFlowLogic::HelloWorld")
    expect(user.account.twilio_account_sid).to eq(twilio_account_sid)
    expect(user.account.twilio_auth_token).to eq(twilio_auth_token)
    expect(user.account.somleng_account_sid).to eq(somleng_account_sid)
    expect(user.account.somleng_auth_token).to eq(somleng_auth_token)
    expect(user.account.settings).to eq(
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
    )
  end
end
