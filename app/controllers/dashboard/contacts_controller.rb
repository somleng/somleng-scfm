class Dashboard::ContactsController < Dashboard::BaseController
  private

  def association_chain
    current_account.contacts
  end

  def permitted_params
    params.require(:contact).permit(:msisdn, METADATA_FIELDS_ATTRIBUTES)
  end

  def prepare_resource_for_update
    clear_metadata
  end

  def resources_path
    dashboard_contacts_path
  end

  def build_key_value_fields
    build_metadata_field
  end
end
