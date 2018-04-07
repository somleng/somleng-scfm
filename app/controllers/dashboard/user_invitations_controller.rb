class Dashboard::UserInvitationsController < Devise::InvitationsController

  private

  def invite_params
    super.merge(account_id: current_inviter.account_id)
  end
end
