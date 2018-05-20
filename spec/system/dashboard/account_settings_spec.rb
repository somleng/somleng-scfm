require "rails_helper"

RSpec.describe "Account Settings" do
  it "can update the account settings" do
    user = create(:admin)
    sign_in(user)

    visit(edit_dashboard_account_path)

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

    fill_in("Twilio Account Sid", with: twilio_account_sid)
    fill_in("Twilio Auth Token", with: twilio_auth_token)
    fill_in("Somleng Account Sid", with: somleng_account_sid)
    fill_in("Somleng Auth Token", with: somleng_auth_token)
    select("Somleng", from: "Platform Provider")
    click_action_button(:update, key: :accounts)

    expect(current_path).to eq(edit_dashboard_account_path)
    expect(page).to have_text("Account was successfully updated.")
    user.account.reload
    expect(user.account.platform_provider_name).to eq("somleng")
    expect(user.account.twilio_account_sid).to eq(twilio_account_sid)
    expect(user.account.twilio_auth_token).to eq(twilio_auth_token)
    expect(user.account.somleng_account_sid).to eq(somleng_account_sid)
    expect(user.account.somleng_auth_token).to eq(somleng_auth_token)
  end
end
