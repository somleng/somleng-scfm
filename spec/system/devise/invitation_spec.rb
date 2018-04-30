require "rails_helper"

RSpec.describe "User invitation", type: :system do
  describe "Send invitation", type: :system do
    it "will send an invitation" do
      admin = create(:admin)
      sign_in(admin)
      visit new_user_invitation_path

      fill_in "Email", with: "bopha@somleng.com"
      clear_enqueued_jobs
      perform_enqueued_jobs do
        click_button "Send an invitation"
      end

      expect(page).to have_text("An invitation email has been sent to bopha@somleng.com.")
      expect(last_email_sent.from).to match_array(
        [Rails.application.secrets.fetch(:mailer_sender)]
      )
    end
  end

  describe "User accept invitation" do
    let(:inviter) { create(:user) }

    it "user can set password then auto sign in" do
      visit accept_user_invitation_path(invitation_token: raw_token)

      fill_in "Password", with: "myscret"
      fill_in "Password confirmation", with: "myscret"
      click_button "Save"

      expect(page).to have_text("Your password was set successfully. You are now signed in.")
    end
  end

  private

  def raw_token
    User.invite!(
      { email: FactoryBot.generate(:email), account_id: inviter.account_id },
      inviter
    ).raw_invitation_token
  end
end
