module ControllerSpecHelpers
  attr_reader :current_user

  def user_signed_in
    user = create(:user)
    sign_in_as(user)
  end

  def sign_in_as(user)
    sign_in(user, scope: :user)
    @current_user = user
  end
end

RSpec.configure do |config|
  config.include(ControllerSpecHelpers, type: :controller)
end
