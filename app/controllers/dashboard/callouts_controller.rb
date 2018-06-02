class Dashboard::CalloutsController < Dashboard::BaseController
  private

  def association_chain
    current_account.callouts
  end

  def permitted_params
    params.require(:callout).permit(:voice, :call_flow_logic, commune_ids: [])
  end

  def before_update_attributes
    clear_metadata
  end

  def resources_path
    dashboard_callouts_path
  end
end
