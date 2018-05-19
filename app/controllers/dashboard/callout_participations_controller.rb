class Dashboard::CalloutParticipationsController < Dashboard::BaseController
  helper_method :parent_show_path

  private

  def association_chain
    if parent
      parent.callout_participations
    else
      current_account.callout_participations
    end
  end

  def parent
    if callout_id
      callout
    elsif callout_population_id
      callout_population
    end
  end

  def callout_id
    params[:callout_id]
  end

  def callout
    @callout ||= current_account.callouts.find(callout_id)
  end

  def callout_population_id
    params[:batch_operation_id]
  end

  def callout_population
    @callout_population ||= current_account.batch_operations.find(callout_population_id)
  end

  def parent_show_path
    if callout_id
      dashboard_callout_path(callout)
    elsif callout_population_id
      dashboard_batch_operation_path(callout_population)
    end
  end

  def resources_path
    dashboard_callout_callout_participations_path(resource.callout)
  end
end
