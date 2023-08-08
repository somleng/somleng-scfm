class Users::RegistrationsController < Devise::RegistrationsController
  layout :resolve_layout

  private

  def resolve_layout
    user_signed_in? ? "dashboard" : "devise"
  end
end
