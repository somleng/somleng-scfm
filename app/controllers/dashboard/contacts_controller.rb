class Dashboard::ContactsController < Dashboard::BaseController
  private

  def save_resource
    resource.save(context: :dashboard)
  end

  def association_chain
    current_account.contacts
  end

  def permitted_params
    params.require(:contact).permit(
      :msisdn,
      :commune_id,
      **METADATA_FIELDS_ATTRIBUTES
    )
  end

  def build_key_value_fields
    resource.build_metadata_field if resource.metadata_fields.empty?
  end

  def before_update_attributes
    clear_metadata
  end
end
