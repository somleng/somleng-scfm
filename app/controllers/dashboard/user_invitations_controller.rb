class Dashboard::UserInvitationsController < Devise::InvitationsController
  protected

  def invite_params
    super.merge(account_id: current_inviter.account_id)
  end

  def after_invite_path_for(_inviter, _invitee = nil)
    dashboard_users_path
  end
end
