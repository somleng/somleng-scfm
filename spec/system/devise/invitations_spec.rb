require "rails_helper"

RSpec.describe "User Invitations" do
  it "can send an invitation", :js do
    user = create(:admin)
    sign_in(user)
    visit new_user_invitation_path

    fill_in "Email", with: "bopha@somleng.com"
    choose "Admin"
    select_selectize("#locations", "Banteay Meanchey")
    clear_enqueued_jobs

    perform_enqueued_jobs do
      click_action_button(:create, key: :"submit.user", namespace: :helpers)
    end

    expect(page).to have_text("An invitation email has been sent to bopha@somleng.com.")
    expect(last_email_sent.from).to match_array(
      [Rails.application.secrets.fetch(:mailer_sender)]
    )

    new_user = user.account.users.find_by!(email: "bopha@somleng.com")
    expect(new_user.roles?(:admin)).to eq true
    expect(new_user.location_ids).to include_location("Banteay Meanchey")
  end

  it "can set the password" do
    inviter = create(:user)
    visit accept_user_invitation_path(invitation_token: invitation_token(inviter))

    within("#page_title") do
      expect(page).to have_content(I18n.translate!(:"titles.user_invitations.edit"))
    end

    fill_in "Password", with: "myscret"
    fill_in "Password confirmation", with: "myscret"
    click_action_button(:update, key: :submit, namespace: :helpers)

    expect(page).to have_text("Your password was set successfully. You are now signed in.")
  end

  def invitation_token(inviter)
    User.invite!(
      { email: generate(:email), account_id: inviter.account_id },
      inviter
    ).raw_invitation_token
  end
end
