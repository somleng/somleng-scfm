class Dashboard::UsersController < Dashboard::BaseController
  private

  def association_chain
    current_account.users
  end

  def build_key_value_fields
    build_metadata_field
  end

  def permitted_params
    params.fetch(:user, {}).permit(METADATA_FIELDS_ATTRIBUTES)
  end
end
