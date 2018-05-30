class Dashboard::ContactsController < Dashboard::BaseController
  private

  def save_resource
    resource.save(context: :dashboard)
  end

  def association_chain
    current_account.contacts
  end

  def permitted_params
    params.require(:contact).permit(:msisdn, :commune_id)
  end

  def before_update_attributes
    clear_metadata
  end

  def resources_path
    dashboard_contacts_path
  end
end
