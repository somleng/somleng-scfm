class Api::UserEventsController < Api::ResourceEventsController
  private

  def parent_resource
    user
  end

  def path_to_parent
    api_user_path(user)
  end

  def user
    @user ||= current_account.users.find(params[:user_id])
  end

  def event_class
    Event::User
  end

  def access_token_write_permissions
    [:users_write]
  end
end
