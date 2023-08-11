require "rails_helper"

RSpec.describe "Account Settings" do
  it "can update the account settings", :js do
    user = create(:user)
    sign_in(user)

    visit(edit_dashboard_account_path)

    expect(page).to have_title("Account Settings")

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
        "from_phone_number" => "1234"
      }
    )

    click_on("Save")

    expect(page).to have_current_path(edit_dashboard_account_path, ignore_query: true)
    expect(page).to have_text("Account was successfully updated.")
    user.account.reload
    expect(user.account.platform_provider_name).to eq("somleng")
    expect(user.account.call_flow_logic).to eq("CallFlowLogic::HelloWorld")
    expect(user.account.twilio_account_sid).to eq(twilio_account_sid)
    expect(user.account.twilio_auth_token).to eq(twilio_auth_token)
    expect(user.account.somleng_account_sid).to eq(somleng_account_sid)
    expect(user.account.somleng_auth_token).to eq(somleng_auth_token)
    expect(user.account.settings).to include("from_phone_number" => "1234")
  end
end
