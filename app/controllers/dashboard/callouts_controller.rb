class Dashboard::CalloutsController < Dashboard::BaseController
  private

  def association_chain
    current_account.callouts
  end

  def permitted_params
    params.require(:callout).permit(:voice, commune_ids: [])
  end

  def prepare_resource_for_update
    clear_metadata
  end

  def resources_path
    dashboard_callouts_path
  end
end
