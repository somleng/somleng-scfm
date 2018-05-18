class Dashboard::SensorsController < Dashboard::AdminController
  private

  def association_chain
    current_account.sensors
  end

  def permitted_params
    params.require(:sensor).permit(:province_id)
  end

  def resources_path
    dashboard_sensors_path
  end
end
