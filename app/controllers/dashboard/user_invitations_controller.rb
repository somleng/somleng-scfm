class Dashboard::UserInvitationsController < Devise::InvitationsController
  before_action :authorize_admin!, only: :new

  private

  def invite_params
    super.merge(account_id: current_inviter.account_id)
  end
end
